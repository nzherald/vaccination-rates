import React from 'react'
import { timeFormat } from 'd3-time-format'
import { format } from 'd3-format'

import XYFrame from "semiotic/lib/XYFrame"
const theme = ["#006a9d","#77a748","#ecb73d","#c8352c","#1a1102","#533f82","#7a255d","#365350","#a19a11","#3f4482"]
const formatTime = timeFormat("%Y");
const monthFormat = timeFormat("%b %Y");
const percent = format('.0%')


const tooltipStyles = {
  background: "rgba(255,255,255,1)",
  minWidth: "max-content",
  whiteSpace: "nowrap",
  fontFamily: "Stag Sans",
  zIndex: 100,
  marginLeft: "10px",
  padding: "3px 1px",
  fontSize: "14px"
}

export default ({data, title, subtitle, note, nokey}) => {
  const frameProps = {
    lines : data ? Object.entries(data).filter(d => d[0] !== 'Dep Unknown' && (data['Asian'] ? (d[0] !== "Total") : true)).map(d => {
      return {title: d[0], coordinates: d[1]}
    }) : [],
    size: [Math.min(600, window.innerWidth),200],
    margin: { left: 50, bottom: 30, right: nokey ? 20 : 100, top: 55 },
    xAccessor: d => new Date(d.Quarter),
    hoverAnnotation: true,
    tooltipContent: d => {
      return (
        <div  className="tooltip-content" style={tooltipStyles}>
          {monthFormat(new Date(d.Quarter)).replace('20', "'")}: {percent(d.Value)}
        </div>
      )},
    yAccessor: "Value",
    lineStyle: (d, i) => ({
      stroke: theme[i],
      strokeWidth: 3,
      fill: "none"
    }),
    title: (
      <g>
        <text fontFamily="Stag Book" fontSize="17" textAnchor="middle" className="chart-title">{title} </text>
        <text y="22" textAnchor="middle" fontSize="16">{subtitle}</text>
      </g>
    ),
    axes: [{ orient: "left", tickFormat: percent },
      { orient: "bottom", ticks: window.innerWidth < 400 ? 3 : 7, tickFormat: formatTime }]

  }
  return (<div>
    <div className="chart-wrapper">
      <div className="chart-legend">
        {nokey || frameProps.lines.map(({title},i) => {
          return (
            <div key={title} className="legend-entry">
              <div className="legend-line" style={{backgroundColor: theme[i]}}></div>
              <div>{title}</div>
            </div>
        )})}
      </div>
      <XYFrame {...frameProps} />
    </div>
    <div className="note">{note}</div>
  </div>
  )
}
