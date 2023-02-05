Run py -m streamlit run dashboard.py in the directory
Once the code is up and running, open http://localhost:8501/ in your browser to interact with the program.

Program Overview:
- I am using python for API calls to IEX Cloud to pull information about a given symbol.
- Information such as company logo, overview, stats, news, etc.
- In order to cut down on the API calls made and thus the number of credits used, I am using redis to cache 
some of the data received from the API call. So for example, if you search for AAPL and then look for another symbol
and then look up AAPL again, this time no API call will be made, rather data will be pulled from cahce depending on the 
info requested.
- Requests for stats and news are making API calls everytime for the most up-to-date information.
- Cached information will expire after 24 hours and an API call will be made if info is requested. 