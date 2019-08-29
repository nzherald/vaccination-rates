import React, { useState } from 'react';
import axios from 'axios';
import ChartCarousel from './ChartCarousel'

import deprivation from "./deprivation.json"
import ethnicity from "./ethnicity.json"
import { homepage } from "../package.json"
import config from "./config.json"

import LineChart from "./LineChart"


// axios.defaults.headers.post['Content-Type'] ='application/json;charset=utf-8';
// axios.defaults.headers.post['Access-Control-Allow-Origin'] = '*';

function App({option}) {
  const [data, setData] = useState({ ethnicity, deprivation });

  // useEffect(() => {
  //   const fetchData = async () => {
  //     const deprivation = await axios.get(homepage + config.deprivation, {
  //       headers: {
  //         "Access-Control-Allow-Origin": "*"
  //       }
  //     })
  //     const ethnicity = await axios.get(homepage + config.ethnicity, {
  //       headers: {
  //         "Access-Control-Allow-Origin": "*"
  //       }
  //     })

  //     setData({deprivation: deprivation.data, ethnicity: ethnicity.data})
  //   };

  //   fetchData();
  // }, []);

  if (option === "total-trend") {
    return (
      <LineChart data={data.ethnicity.National ? {"Total": data.ethnicity.National.Total} : {}}
      title="Vaccinated infants in New Zealand"
      nokey={true} />
    )
  }

  if (option === "total-eth") {
    return (
      <LineChart data={data.ethnicity.National}
      title="Vaccinated infants in New Zealand"
      subtitle="Grouped by Ethnicity"
    />
    )
  }

  if (option === "total-dep") {
    return (
      <LineChart data={data.deprivation.National}
      title="Vaccinated infants in New Zealand"
      subtitle="Grouped by Deprivation levels"
      note="Level 1 is the least deprived"
    />
    )
  }

  return (
    <ChartCarousel data={data} />
  );
}

export default App;



