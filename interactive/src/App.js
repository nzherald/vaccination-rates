import React, { useState, useEffect } from 'react';
import axios from 'axios';
import ChartCarousel from './ChartCarousel'

import config from "./config.json"
import { homepage } from "../package.json"

import LineChart from "./LineChart"

function App({option}) {
  const [data, setData] = useState({ ethnicity: {}, deprivation: {} });

  useEffect(() => {
    const fetchData = async () => {
      const deprivation = await axios(homepage + config.deprivation)
      const ethnicity = await axios(homepage + config.ethnicity)

      setData({deprivation: deprivation.data, ethnicity: ethnicity.data})
    };

    fetchData();
  }, []);

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



