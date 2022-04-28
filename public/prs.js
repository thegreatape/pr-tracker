const displaylist = {
  "Bench Press": "#FE5F55",
  "Deadlift": "#F0B67F",
  "Front Squat": "#5B7B7A",
  "Overhead Press": "#593F62",
  "Safety Bar Squat": "#355834",
  "Squat": "#3C887E",
  "Trap Bar Deadlift": "#A17C6B",
}

const filteredData = _.filter(window.prData, function(d) {return !!displaylist[d.label]})
const coloredData = _.map(filteredData, function(d) {
  d.backgroundColor = displaylist[d.label]
  return d
})

const byRepRangeData = _.map(coloredData, function(d) {
  return _.merge({}, d, {
    data:  _.map(d.data, function(point) {
      return _.merge({}, point, {
        x: point.date,
        y: point.reps
      });
    })
  });
});

const byWeightData = _.map(coloredData, function(d) {
  return _.merge({}, d, {
    data:  _.map(d.data, function(point) {
      return _.merge({}, point, {
        x: point.date,
        y: point.weight_lbs
      });
    })
  });
});

const config = {
  type: 'bubble',
  options: {
    plugins: {
      tooltip: {
        callbacks: {
          label: function(context) {
            // TODO actually use date-fns here
            const date = context.formattedValue.split(', 12')[0].replace("(", "")

            return [
              context.label,
              "-",
              context.raw.reps,
              "x",
              context.raw.weight_lbs+ "lbs",
              "-",
              date
            ].join(" ");
          }
        }
      }
    },
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

const repRangeChart = new Chart(
  document.getElementById('byRepRange'),
  _.merge({}, config, {
    data: {
      datasets: byRepRangeData,
    },
    options: {
      scales: {
        y: {
          title: {
            display: true,
            text: 'Reps'
          }
        },
      },
      plugins: {
        title: {
          display: true,
          text: 'PRs By Rep Range'
        }
      }
    }
  })
);

const weightChart = new Chart(
  document.getElementById('byWeight'),
  _.merge({}, config, {
    data: {
      datasets: byWeightData
    },
    options: {
      scales: {
        y: {
          title: {
            display: true,
            text: 'Weight (lbs)'
          }
        },
      },
      plugins: {
        title: {
          display: true,
          text: 'PRs By Weight'
        }
      }
    }
  })
);
