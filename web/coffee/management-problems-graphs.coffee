ProblemSubmissionDoughnut = React.createClass
  componentDidUpdate: ->
    if @props.visible
      ctx = @getDOMNode().getContext "2d"
      data = [
        {
          value: @props.invalid
          color:"#F7464A"
          highlight: "#FF5A5E"
          label: "Invalid submissions"
        },
        {
          value: @props.valid
          color: "#46BFBD"
          highlight: "#5AD3D1"
          label: "Valid submissions"
        }
      ]

      (new Chart ctx).Doughnut data,
        animateRotate: false

  render: ->
    <canvas height="300" width="300"/>
