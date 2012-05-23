# Ply. A company dashboard.

An attempt to make a dashboard suitable for large displays, personal computers and mobile devices where the server-side provides the initial frames and the data stream AND the client-side logic does the rest.

## The focus

* Rails for the backend
* MongoDB for the DB thingos, brought to you by Mongoid
* EmberJS for the client-side

The focus is on writing your apps in JavaScript (or CoffeeScript at some point) and only worrying about server side (Ruby) code for the web services. Browsers are awesome and fast and strong so let's take advantage of them.

## Frames

Like a slide or page, a frame is a specific thing you want to show onscreen. It could be a fancy D3 graph, error logs or just the current time.

You define them each as a controller, hopefully extended from FrameController. You declare your initial frame and then all the specific data services associated with that, when it comes time for the client side to load it your initial frame is brought in and all your relevant web services and polled.