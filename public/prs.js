const displaylist = {
  "Bench Press": "#FE5F55",
  "Deadlift": "#F0B67F",
  "Front Squat": "#5B7B7A",
  "Overhead Press": "#593F62",
  "Safety Bar Squat": "#E0F2E9",
  "Squat": "#3C887E",
  "Trap Bar Deadlift": "#A17C6B",
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
