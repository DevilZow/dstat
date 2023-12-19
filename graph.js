$(function () {
  var mychart;
  var previous = null;
  var count = 0;
  $(window).load(function () {
    initiateChart("graphdstat");
    parseFile();
  });

  function parseFile() {
    // actually skidded from vshield, gonna recode it
    $.ajax({
      url: "/nginx_status",
      dataType: "text",
      cache: false,
    })
      .done(function (data) {
        var current = 0;
        var part = data.split(" ")[9];
        var series = mychart.series[0],
          current = parseInt(part);
        shift = series.data.length > 40;
        if (previous !== null) {
          series.addPoint(
            [Math.floor($.now()), current - previous],
            true,
            shift
          );
        }
        previous = current;
        count++;
        // call it again after one second
        setTimeout(parseFile, 1000);
      })
      .fail(function (jqXHR, textStatus, errorThrown) {
        console.log(errorThrown);
      });
  }

  function initiateChart(divid) {
    mychart = Highcharts.chart("container", {
      chart: {
        type: "area",
        backgroundColor: "#363132",
      },
      title: {
        text: "r/s",
      },
      xAxis: {
        type: "datetime",
        dateTimeLabelFormats: {
          day: "%a",
        },
        gridLineColor: "#940B92",
        labels: {
          style: {
            color: "#940B92",
          },
        },
      },
      yAxis: {
        allowDecimals: false,
        labels: {
          formatter: function () {
            if (this.value > 1000) {
              return this.value / 1000 + "k r/s";
            } else {
              return this.value + " r/s";
            }
          },
        },
      },
      tooltip: {
        pointFormat: "Requests:  {point.y:,.0f}",
      },
      colors: [
        { linearGradient: [0, 0, 0, 0], stops: [[0, "rgba(120,81,169,1)"]] },
      ],
      plotOptions: {
        area: {
          fillColor: {
            linearGradient: {
              x1: 0,
              y1: 0,
              x2: 0,
              y2: 1,
            },
            stops: [
              [0, "#DA0C81"],
              [1, new Highcharts.Color("#DA0C81").setOpacity(0).get("rgba")],
            ],
          },
          pointStart: 1940,
          marker: {
            enabled: true,
            symbol: "circle",
            radius: 2,
            states: {
              hover: {
                enabled: true,
              },
            },
          },
        },
      },
      series: [
        {
          name: "Requests",
          data: [],
        },
      ],
    });
  }
});
