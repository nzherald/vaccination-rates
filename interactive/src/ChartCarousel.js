import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { Carousel } from 'react-responsive-carousel'


import LineChart from "./LineChart"

const label = function(dhb) {
  if (dhb === "National") {
    return "All of New Zealand"
  }
  return dhb + " DHB"
}

export default ({data}) => {
  const ethnicity = Object.entries(data.ethnicity)
  return ( 
    <Carousel showThumbs={false} infiniteLoop showStatus={false} showIndicators={false}  selectedItem={16} >
      {Object.entries(data.deprivation).map((d,i) => (

        <div key={d[0]}>
          <LineChart data={d[1]} title={label(d[0])} subtitle="Vaccinated infants by deprivation levels" note="Level 1 is the least deprived" />
          <LineChart data={ethnicity[i][1]} subtitle="Vaccinated infants by ethnicity" style={{marginTop: "-15px"}} />
        </div>)
      )}
    </Carousel>
  )
}
