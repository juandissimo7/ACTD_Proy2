###Paqueterias necesarias

library(quantmod)
library(xts)
library(dygraphs)
library(dplyr)
library(tidyverse)
library(fpp)
library(forecast)
library(lubridate)
library(TSA)
library(aTSA)
library(Metrics)
library(forecast)
library(TSstudio)
library(fpp2)
library(fUnitRoots)
library(ggplot2)
library(tseries)

option(warn = -1)

###Funcion de precio

start<-format(as.Date("2017-01-01"),"%Y-%m-%d")
end<-format(as.Date("2021-01-01"),"%Y-%m-%d")

precios <-function(simbolo)
{
  ##Obtener precios stocks de Yahoo FInance
  datos <- getSymbols(simbolo, auto.assign = FALSE, from=start, to=end)
  ## Elimar faltantes:
  datos<-na.omit(datos)
  ##mantener columnas con precios cierre y volumenes: columnas 4 y 5:
  datos <- datos[,6]
  ##Para hacerlo datos accesibles en el global environment:
  assign(simbolo, datos, envir = .GlobalEnv)
}

##Llamar la funcion para netflix:

p_netflix=precios("NFLX")

##Podemos graficar:
plot(p_netflix, ylab="Index", main='NFLX')
lines(density(p_netflix), lwd = 3, col = 'red')
length(p_netflix)

##Partimos serie, tomemos el 20% para la prueba
h <- round(length(p_netflix)*0.2, digits = 0 )
h
n_train <- p_netflix[1:(nrow(p_netflix) - h), ]
n_test<- p_netflix[(nrow(p_netflix) - h + 1):nrow(p_netflix), ]


### Graficas

a=acf(n_train,lag.max = 800)
p=pacf(n_train,lag.max = 800)

plot(a)
plot(p)

### Test estacionario

phillips=stationary.test(n_train, method = c("pp"))

### Diferenciacion

ndiffs(n_train)
d_n_train<-diff(n_train)[-1,]

### Nuevo test

phillips_dif=stationary.test(d_n_train, method = c("pp"))

### Nuevas graficas

ad=acf(d_n_train)
pd=pacf(d_n_train)

plot(ad)
plot(pd)

    #' Posible AR=3,MA=3

### Obtencion con eacf

ed=eacf(n_train, ar.max = 7, ma.max = 7)

    #' Posible AR=1,MA=3
    
### Obtencion con auto.arima

autoari=auto.arima(n_train)
    #'Posible AR=0, MA=3
summary(autoari)


### Modelamiento

mod1_ar3_ma3=Arima(n_train, order=c(3,1,3), method = "ML")
mod1_ar3_ma3$aic
plot(mod1_ar3_ma3$residuals  )
hist(mod1_ar3_ma3$residuals  )

mod2_ar1_ma3=Arima(n_train, order=c(1,1,3), method = "ML")
mod2_ar1_ma3$aic
plot(mod2_ar1_ma3$residuals  )
hist(mod2_ar1_ma3$residuals  )

mod3_ar0_ma3=Arima(n_train, order=c(0,1,3), method = "ML")

plot(mod3_ar0_ma3$residuals  )
hist(mod3_ar0_ma3$residuals  )


qqnorm(mod1_ar3_ma3$residuals, main='ARIMA 3,1,3')
qqline(mod1_ar3_ma3$residuals, col="red")

qqnorm(mod2_ar1_ma3$residuals, main='ARIMA 1,1,3')
qqline(mod2_ar1_ma3$residuals, col="red")

qqnorm(mod3_ar0_ma3$residuals, main='ARIMA 0,1,3')
qqline(mod3_ar0_ma3$residuals, col="red")

### Pronosticos 

mod1_ar3_ma3%>% forecast::forecast(h=200)%>% autoplot(include=800)  
mod2_ar1_ma3%>% forecast::forecast(h=200)%>% autoplot(include=800)
mod3_ar0_ma3%>% forecast::forecast(h=200)%>% autoplot(include=800)

pred.mod1=forecast::forecast(mod1_ar3_ma3,h=201)
pred.mod2=forecast::forecast(mod2_ar1_ma3,h=201)
pred.mod3=forecast::forecast(mod3_ar0_ma3,h=201)

### Comparaicones

rmse(n_test, pred.mod1$mean)
rmse(n_test, pred.mod2$mean)
rmse(n_test, pred.mod3$mean)

### DataFrame

dfmod1_ar3ma3=data.frame(cbind(pred.mod1$lower,pred.mod1$upper))
dfmod2_ar1ma3=data.frame(cbind(pred.mod2$lower,pred.mod2$upper))
dfmod3_ar0ma3=data.frame(cbind(pred.mod3$lower,pred.mod3$upper))

write.csv(dfmod1_ar3ma3, 'C:/Users/juand/Downloads/fcast_ar3ma3.csv')
write.csv(dfmod2_ar1ma3, 'C:/Users/juand/Downloads/fcast_ar1ma3.csv')
write.csv(dfmod3_ar0ma3, 'C:/Users/juand/Downloads/fcast_ar0ma3.csv')


plot(n_test)
lines(pred.mod1$lower[,2], col='red')

length(n_test)
length()

plot(pred.mod1$lower[,2])
lines(as.data.frame(n_test))

### Grafico comparativo al 95% de predicciones
plot(as.vector(n_test), type='l',ylim=c(100,700),lwd=2, main='95% confidence forecast NFLX', ylab="Price")
lines(as.vector(pred.mod1$lower[,2]), col=2, lwd=2, lty=3)
lines(as.vector(pred.mod1$upper[,2]), col=2, lwd=2,lty=3)
lines(as.vector(pred.mod2$lower[,2]), col=3, lwd=3,lty=2)
lines(as.vector(pred.mod2$upper[,2]), col=3,lwd=2,lty=2)
lines(as.vector(pred.mod3$lower[,2]), col=4, lwd=2,lty=1)
lines(as.vector(pred.mod3$upper[,2]), col=4, lwd=2,lty=1)
legend(x='topleft', legend = c("ARMA 3,1,3", "ARMA 1,1,3", "ARMA 0,1,3"),
         col=c(2,3,4), lty = c(3,2,1), lwd=c(2,2,2))







