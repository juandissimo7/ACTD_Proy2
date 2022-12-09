# -*- coding: utf-8 -*-
"""
Created on Thu Dec  8 19:21:37 2022

@author: juli
#mencion especial a la ayuda de yputube e internet para lograr de alguna manera este tablero.
"""

import dash
import dash_bootstrap_components as dbc
import dash_html_components as html
import dash_core_components as dcc
import plotly.express as px
from dash.dependencies import Input, Output
import pandas as pd
import base64
import numpy as np
import pandas as pd
import statsmodels.api as sm
import statsmodels.tsa as tsm
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec
from statsmodels.formula.api import ols
from scipy import stats
from astsadata import *
import matplotlib.pyplot as plt
#import prueba as pb

df=pd.read_csv("NFLXR.csv")
#del df["Fecha"]
#print(df)
df_train= df[0:900]
#print(df_train)
df_try=df[900:]
#print(df_try)
def predictionU():
    regr = sm.tsa.AutoReg(df["NFLX"], lags=100).fit()
    fore = regr.get_prediction(start=len(df["NFLX"]), end=len(df["NFLX"]) + 100)

    
    dfU=fore.predicted_mean + fore.se_mean
    return dfU
def predictionL():
    regr = sm.tsa.AutoReg(df["NFLX"], lags=100).fit()
    fore = regr.get_prediction(start=len(df["NFLX"]), end=len(df["NFLX"]) + 100)

    dfL=fore.predicted_mean - fore.se_mean
    return dfL

pdL=predictionL()
pdU=predictionU()


app = dash.Dash(__name__, external_stylesheets=[dbc.themes.BOOTSTRAP])

# styling the sidebar
SIDEBAR_STYLE = {
    "position": "fixed",
    "top": 0,
    "left": 0,
    "bottom": 0,
    "width": "20rem",
    "padding": "2rem 1rem",
    "background-color": "#f8f9fa",
}

# padding for the page content
CONTENT_STYLE = {
    "margin-left": "20rem",
    "margin-right": "5rem",
    "padding": "2rem 1rem",
}

sidebar = html.Div(
    [
        html.H2("Options", className="display-3"),
        html.Hr(),
        html.P(
            "Netflix stock prediction center", className="lead"
        ),
        dbc.Nav(
            [
                dbc.NavLink("Purpose", href="/", active="exact"),
                dbc.NavLink("Stock Graph", href="/StockGraph", active="exact"),
                dbc.NavLink("Stock prediction", href="/StockPrediction", active="exact"),
                dbc.NavLink("Stock prediction 2", href="/StockPrediction2", active="exact"),
                dbc.NavLink("Stock futute", href="/StockFuture", active="exact"),
                
            ],
            vertical=True,
            pills=True,
        ),
    ],
    style=SIDEBAR_STYLE,
)

content = html.Div(id="page-content", children=[], style=CONTENT_STYLE)

app.layout = html.Div([
    dcc.Location(id="url"),
    sidebar,
    content
])



#image_filename1 = 'netflix.png' # replace with your own image
#encoded_image1 = base64.b64encode(open(image_filename1, 'rb').read())

#image1_path="/Users/crive/OneDrive/Documents/SEMESTRE7/analiticaComp/Proyecto 2/prediction1.png"

test_png1 = 'prediction1.png'
test_base64 = base64.b64encode(open(test_png1, 'rb').read()).decode('ascii')
test_png2 = 'netflix.png'
test_base64_1 = base64.b64encode(open(test_png2, 'rb').read()).decode('ascii')
test_png3 = 'predictionfuture.png'
test_base64_2 = base64.b64encode(open(test_png3, 'rb').read()).decode('ascii')
test_png4 = 'predictionR.png'
test_base64_3 = base64.b64encode(open(test_png4, 'rb').read()).decode('ascii')

@app.callback(
    Output("page-content", "children"),
    [Input("url", "pathname")]
)
def render_page_content(pathname):
    if pathname == "/":
        return [
                html.H1("Netflix stock prediction center",
                        style={'textAlign':'center'}),
                html.H6("The purpose of this application is to show the trends of the netflix stock and try to predict how will it change in the future days. We hope that you as an Netflix investor can get big rewards by using this application",
                        style={'textAlign':'center'}),
                html.Div([
                html.Img(src='data:image/png;base64,{}'.format(test_base64_1),
                         style={'height': '50%',
                                'width': '50%'})
                ], style={'textAlign': 'center'})
                
                ]
    elif pathname == "/StockGraph":
        return [
                html.H1('Netflix Stock Price Graph',
                        style={'textAlign':'center'}),
                dcc.Graph(id='linegraph',
                         figure=px.line(df, x="Fecha", y="NFLX", title='NFLX stock Price'))
                ]
    elif pathname == "/StockPrediction":
        return [
                html.H1('Netflix Stock Price Prediction ',
                        style={'textAlign':'center'}),
                html.H6("This graph shows our predicted model working with past data, in this graph we compare our results with the real stock value in 2021",
                        style={'textAlign':'center'}),
                html.Img(src='data:image/png;base64,{}'.format(test_base64))
                #dcc.Graph(id='bargraph',
                         # figure=pb.prediction()
                         
                ]
    elif pathname == "/StockPrediction2":
        return [
                html.H1('Netflix Stock Price Prediction 2',
                        style={'textAlign':'center'}),
                html.H6("This graph shows our predicted model working with past data,this time doing it with other progamming language, both are similar showing robustness and credibility to our model",
                        style={'textAlign':'center'}),
                html.Img(src='data:image/png;base64,{}'.format(test_base64_3))
                
                ]
    elif pathname == "/StockFuture":
        return [
                html.H1('Predict values for the fist hundred days of 2022',
                        style={'textAlign':'center'}),
                html.H6("This graph shows what we believe the values of netflix for the first hundred days of 2022 will oscilate",
                        style={'textAlign':'center'}),
                html.Img(src='data:image/png;base64,{}'.format(test_base64_2))
                
                ]
    else:
        return dbc.Container(
        [
            html.H1("404: Not found", className="text-danger"),
            html.Hr(),
            html.P(f"The pathname {pathname} was not recognized..."),
        ]
        )


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)