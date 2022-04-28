const displaylist = {
  'Squat': 'yellow',
  'Overhead Press': 'red',
  'Overhead press': 'red',
  'Front Squat': 'green',
  'Front squat': 'green'
}

const filteredData = _.filter(window.prData, function(d) {return !!displaylist[d.label]})
const coloredData = _.map(filteredData, function(d) {
  d.backgroundColor = displaylist[d.label]
  return d
})

console.log(coloredData)

const data = {
  datasets: coloredData
  //datasets: window.prData
};

const config = {
  type: 'bubble',
  data: data,
  options: {
    scales: {
      x: {
        type: 'time',
        time: {
          unit: 'month'
        }
      }
    }
  }
};

const myChart = new Chart(
  document.getElementById('myChart'),
  config
);
