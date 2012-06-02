# Ply. A company dashboard.

An attempt to make a dashboard suitable for large displays, personal computers and mobile devices where the server-side provides the initial boards and the data stream AND the client-side logic does the rest.

## The focus

* Rails for the backend
* MongoDB for the DB thingos, brought to you by Mongoid
* EmberJS for the client-side

The focus is on writing your apps in JavaScript (or CoffeeScript at some point) and only worrying about server side (Ruby) code for the web services. Browsers are awesome and fast and strong so let's take advantage of them.

## Boards

Like a slide or page, a board is a specific thing you want to show onscreen. It could be a fancy D3 graph, error logs or just the current time.

You define them each in a DSL fashion, inside ply/boards you add your specific board and declare the initial render to perform and any support web services (see ply/boards/time). You declare your initial board and then all the specific data services associated with that, when it comes time for the client side to load it your initial board is brought in and all your relevant web services and polled.