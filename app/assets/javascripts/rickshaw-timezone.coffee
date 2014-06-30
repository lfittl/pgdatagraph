Rickshaw.namespace('Rickshaw.Fixtures.TimeWithTimezone');

class Rickshaw.Fixtures.TimeWithTimezone

  constructor: (timezone) ->
    @makeMoment = (d) -> moment(d).tz(timezone)
    @units = [
      name: 'decade',
      seconds: 86400 * 365.25 * 10,
      formatter: (d) => (parseInt(@makeMoment(d).format("YYYY") / 10, 10) * 10)
    ,
      name: 'year',
      seconds: 86400 * 365.25,
      formatter: (d) => @makeMoment(d).format("YYYY")
    ,
      name: 'month',
      seconds: 86400 * 30.5,
      formatter: (d) => @makeMoment(d).format("MMM")
    ,
      name: 'week',
      seconds: 86400 * 7,
      formatter: (d) => @makeMoment(d).format("MMM D")
    ,
      name: 'day',
      seconds: 86400,
      formatter: (d) => @makeMoment(d).format("Do")
    ,
      name: '6 hour',
      seconds: 3600 * 6,
      formatter: (d) => @makeMoment(d).format("HH:mm")
    ,
      name: 'hour',
      seconds: 3600,
      formatter: (d) => @makeMoment(d).format("HH:mm")
    ,
      name: '15 minute',
      seconds: 60 * 15,
      formatter: (d) => @makeMoment(d).format("HH:mm")
    ,
      name: 'minute',
      seconds: 60,
      formatter: (d) -> @makeMoment(d).format("m")
    ,
      name: '15 second',
      seconds: 15,
      formatter: (d) -> @makeMoment(d).format("s") + 's'
    ,
      name: 'second',
      seconds: 1,
      formatter: (d) -> @makeMoment(d).format("s") + 's'
    ,
      name: 'decisecond',
      seconds: 1 / 10,
      formatter: (d) -> @makeMoment(d).format("SSS") + 'ms'
    ,
      name: 'centisecond',
      seconds: 1 / 100,
      formatter: (d) -> @makeMoment(d).format("SSS") + 'ms'
    ]

  unit: (unitName) ->
    @units.filter((unit) -> unitName == unit.name).shift()

  ceil: (time, unit) ->
    time = @makeMoment(time)

    if unit.name == 'month'
      floor = moment(time).startOf('month')
      if floor != time
        floor.add("months", 1)
      return floor.unix()

    if unit.name == 'year'
      floor = moment(time).startOf('year')
      if floor != time
        floor.add("years", 1)
      return floor.unix()

    Math.ceil(time.unix() / unit.seconds) * unit.seconds