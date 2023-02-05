import streamlit as st
import config, json, redis
from iex import IEXStock
from helpers import format_number, format_long_number
from datetime import datetime, timedelta

redis_client = redis.Redis(host='localhost', port=6379, db=0) #starts the redis clint and the variable can be used to call redis as normal

symbol = st.sidebar.text_input("Symbol", value="AAPL") #specifies the symbol to start off with

stock = IEXStock(config.IEX_API_TOKEN, symbol)
screen = st.sidebar.selectbox("View", ('Overview', 'Stats', 'News', 'Technicals')) #to edit the different tabs you can click on in the drop down

st.title(screen)

#when user clicks on Overview tab
if screen == 'Overview':
    logo_key = f"{symbol}_logo"
    logo = redis_client.get(logo_key)

    if logo is None:    #if the logo is not cached in redis
        print("Could not find logo in cache, retrieving from IEX Cloud API")
        logo = stock.get_logo()
        redis_client.set(logo_key, json.dumps(logo))
        redis_client.expire(logo_key, timedelta(seconds=86400))
    else:   #if logo is present in cache
        print("Found logo in cache, serving from redis")
        logo = json.loads(logo) #loads from the cahce instead of calling IEX API
    
    company_key = f"{symbol}_company"
    company = redis_client.get(company_key)

    if company is None:
        print("Could not find company info in cache, retrieving from IEX Cloud API")
        company = stock.get_company_info()
        redis_client.set(company_key, json.dumps(company))
        redis_client.expire(company_key, timedelta(seconds=86400))
    else:
        print("Found company info in cache, serving from redis")
        company = json.loads(company)

    col1, col2 = st.columns([1,4])  #can create columns like st.columns(2) or as st.columns([1,4]) to give ratios

    with col1:  #specify what you want under each column
        st.image(logo['url'])
    
    with col2:
        st.subheader(company['companyName'])
        st.subheader('Description')
        st.write(company['description'])
        st.subheader('Industry')
        st.write(company['industry'])
        st.subheader('CEO')
        st.write(company['CEO'])

#when user clicks on Stats tab
if screen == 'Stats':
    stats_key = f"{symbol}_stats"
    stats = redis_client.get(stats_key)

    if stats is None:
        print("Could not find stats in cache, retrieving from IEX Cloud API")
        stats = stock.get_stats()
        redis_client.set(stats_key, json.dumps(stats))
        redis_client.expire(stats_key, timedelta(seconds=86400))
    else:
        print("Found stats in cache, serving from redis")
        stats = json.loads(stats)

    col1, col2, col3 = st.columns([1,1,2])

    with col1:
        st.subheader('Number of Employees')
        st.write(format_number(stats['employees']))
        st.subheader('Market Cap')
        st.write("$" + format_number(stats['marketcap']))
        st.subheader('52 Week High')
        st.write(format_number(stats['week52high']))
        st.subheader('52 Week Low')
        st.write(format_long_number(stats['week52low']))
        st.subheader('52 Week Change')
        st.write(format_long_number(stats['week52change']))
        st.subheader('Shares Outstanding')
        st.write(format_number(stats['sharesOutstanding']))
    
    with col3:
        st.subheader('Dividend Rate')
        st.write(format_long_number(stats['ttmDividendRate']))
        st.subheader('Dividend Yield')
        st.write(format_long_number(stats['dividendYield']))
        st.subheader('Next Dividend')
        st.write(stats['nextDividendDate'])
        st.subheader('Ex Dividend')
        st.write(stats['exDividendDate'])
        st.subheader('Next Earnings Date')
        st.write(stats['nextEarningsDate'])
        st.subheader('PE Ratio')
        st.write(format_long_number(stats['peRatio']))
        st.subheader('Beta')
        st.write(format_long_number(stats['beta']))
        st.subheader('Average 10 Day Volume')
        st.write(format_number(stats['avg10Volume']))
        st.subheader('Average 30 Day Volume')
        st.write(format_number(stats['avg30Volume']))

#when user clicks on News tab
if screen == 'News':
    news = stock.get_company_news()

    for article in news:
        st.subheader(article['headline'])
        dt = datetime.fromtimestamp(article['datetime']/1000).isoformat()
        st.write(f"Posted by {article['source']} at {dt}")
        st.write(article['url'])
        st.write(article['summary'])
        st.image(article['image'])
        st.markdown("""---""")

#when user clicks on Technicals tab
if screen == 'Technicals':
    dividends = stock.get_dividends()

    st.header("Dividends")
    for dividend in dividends:
        st.write(dividend['paymentDate'])
        st.write(dividend['amount'])