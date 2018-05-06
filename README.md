# Taller de splines

## Propósito

Estudiar algunos tipos de curvas paramétricas y sus propiedades.

## Tarea

Implemente las curvas cúbicas naturales, de Hermite y Bezier (cúbica y de grado 7), de acuerdo a las indicaciones del sketch adjunto.

*Sugerencia:* Como las curvas de Hermite y cúbica de Bezier requieren varias secciones, reacomode los puntos de control para que su continuidad sea C<sup>1</sup>. Ver [acá](https://visualcomputing.github.io/Curves/#/5/5) y [propiedad 4 de acá](https://visualcomputing.github.io/Curves/#/6/4).

## Profundización

Represente los _boids_ del [FlockOfBoids](https://github.com/VisualComputing/framesjs/tree/processing/examples/Advanced/FlockOfBoids) mediante superficies de spline.

## Integrantes

Máximo 3.

Complete la tabla:

|    Integrante    | github nick |
|------------------|-------------|
| Eduardo Galeano  | cegard     |
| Jhonatan Guzmán  | Jhonnyguzz    |

## Referencias

[Curvas cúbicas naturales y Hermite](http://www.inf-cr.uclm.es/www/cglez/downloads/docencia/AC/splines.pdf)
[Curva de Bezier (Spline cúbico)](https://visualcomputing.github.io/Curves/#/6/6)
[Curva de Bezier de Grado 7](https://es.wikipedia.org/wiki/Curva_de_B%C3%A9zier#Generalizaci%C3%B3n)

## README

Con la tecla R se cambian los puntos de control para ver diferentes curvas con diferentes puntos, El modo se cambia con la tecla espacio y el orden es así:

1. Natural
2. Hermite
3. Bezier cúbico
4. Bezier (Función de processing)
5. Bezier de grado 7 

## Entrega

* Modo de entrega: Haga [fork](https://help.github.com/articles/fork-a-repo/) de la plantilla e informe la url del repo en la hoja *urls* de la plantilla compartida (una sola vez por grupo). Plazo: 6/5/18 a las 24h.
