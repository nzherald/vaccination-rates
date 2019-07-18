import Base from "./lib/base.js"
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import "./root.less"
import "react-responsive-carousel/lib/styles/carousel.css"


if (!Object.entries) {
  Object.entries = function( obj ){
    var ownProps = Object.keys( obj ),
        i = ownProps.length,
        resArray = new Array(i); // preallocate the Array
    while (i--)
      resArray[i] = [ownProps[i], obj[ownProps[i]]];
    
    return resArray;
  };
}


class Main extends Base {
    constructor () {
        super()
        console.log("Setting up visualisation...")
        const chartCarousel = document.getElementById("nzh-datavis-root__carousel")
        const totalTrend = document.getElementById("nzh-datavis-root")
        const totalEth = document.getElementById("nzh-datavis-root__nzeth")
        const totalDep = document.getElementById("nzh-datavis-root__nzdep")
        this.premiumWait(() => {
            if (chartCarousel) {
            ReactDOM.render(<App />, chartCarousel)
        }
        if (totalTrend) {

            ReactDOM.render(<App option="total-trend"/>, totalTrend)
        }
        if (totalEth) {
            ReactDOM.render(<App option="total-eth"/>, totalEth)
        }
        if (totalDep) {
            ReactDOM.render(<App option="total-dep"/>, totalDep)
        }
            console.log("Rendering...")
            console.log("Done.")
        })
    }
}

new Main()
