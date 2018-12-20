import plotly.plotly 
import plotly.graph_objs as go
import plotly.tools as tls
import numpy as np
from scipy.io import loadmat
import os

gaiaData = loadmat('tmp.mat')

x_data = gaiaData['lo']
y_data = gaiaData['la']
z_data = gaiaData['z']

path_x = gaiaData['p_x']
path_y = gaiaData['p_y']
path_z = gaiaData['p_z']

opts = gaiaData['opts']

os.remove('tmp.mat')

terrain = go.Surface(
    x=x_data,
    y=y_data,
    z=z_data,
    contours=go.surface.Contours(
        x=go.surface.contours.X(highlight=False),
        y=go.surface.contours.Y(highlight=False),
        z=go.surface.contours.Z(highlight=False),
    ),
    opacity=1.0
)


path = go.Scatter3d(
    x=path_x[0],
    y=path_y[0],
    z=path_z[0],
    mode='markers',
    marker=dict(
        size=3,
        line=dict(
            color='rgba(217, 217, 217, 1)',
            width=0
        ),
        opacity=0.8
    )
)

data = [terrain, path]

layout = go.Layout(
    title='Mt Bruno Elevation',
    autosize=False,
    width=500,
    height=500,
    margin=dict(
        l=65,
        r=50,
        b=65,
        t=90
    )
)

layout = go.Layout(
    scene=go.layout.Scene(
        xaxis = go.layout.scene.XAxis(showspikes=False),
        yaxis = go.layout.scene.YAxis(showspikes=False),
        zaxis = go.layout.scene.ZAxis(showspikes=False),
    )
)

fig = go.Figure(data=data, layout=layout)

# draw axes in proportion to the proportion of their ranges
fig['layout']['scene'].update(go.layout.Scene(aspectmode='data'))
fig['layout']['scene'].update(go.layout.Scene(hovermode=False))

file = opts['file'][0][0][0]
file = 'Data/PROCESSED/'+file[:len(file)-4]+'.html'

plotlyjs = opts['local'][0][0][0][0]

plotly.offline.plot(fig, filename=file, include_plotlyjs=plotlyjs)