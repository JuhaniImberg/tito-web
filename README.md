# tito-web

## building

    npm install
    sudo npm install -g browserify watchify coffeeify coffee-script
    watchify -t coffeeify app.coffee -o build/bundle.js -v

## license

GPLv3, see `COPYING`