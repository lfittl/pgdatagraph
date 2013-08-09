class PG

  constructor: ->
    ua = navigator.userAgent.toLowerCase()
    client = /(chrome)[ \/]([\w.]+)/.exec(ua) or
      /(webkit)[ \/]([\w.]+)/.exec(ua) or
      /(opera)(?:.*version|)[ \/]([\w.]+)/.exec(ua) or
      /(msie) ([\w.]+)/.exec( ua ) or
      ua.indexOf("compatible") < 0 and /(mozilla)(?:.*? rv:([\w.]+)|)/.exec(ua) or
      []

    @browser = client[1]
    @[@browser] = yes if @browser.length > 0 and $.trim(@browser) isnt ""
    @browserVersion = client[2]

window.PG = new PG()

