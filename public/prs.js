const labels = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
];

const data = {
  datasets: window.prData
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
