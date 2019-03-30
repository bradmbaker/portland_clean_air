import tweepy
import csv
import re

# credentials
consumer_key = ''
consumer_secret = ''
access_token = ''
access_token_secret = ''

auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
auth.set_access_token(access_token, access_token_secret)
api = tweepy.API(auth, wait_on_rate_limit=True)

# Open/Create a file to append data
csvFile = open('all_no_i5_tweets.csv', 'a')

# Use csv Writer
csvWriter = csv.writer(csvFile)


def create_url(tweet_id):
    return "http://www.twitter.com/statuses/" + str(tweet_id)


def remove_linebreaks(tweet_text):
    return re.sub(r'\n', ' ', tweet_text)


# NoI5RQX hashtag
for tweet in tweepy.Cursor(api.search, q="#NOI5RQX", count=100,
                           lang="en",
                           since="2019-02-01").items():
    print (tweet.created_at, tweet.id, tweet.text)
    csvWriter.writerow([tweet.created_at,
                        create_url(tweet.id),
                        tweet.user.screen_name,
                        remove_linebreaks(tweet.text.encode('utf-8'))])

# Joe cortright and ODOT
for tweet in tweepy.Cursor(api.search, q="@joe_cortright", count=100,
                           lang="en",
                           since="2019-02-01").items():
    if re.search('@OregonDOT', tweet.text):
        print (tweet.created_at, tweet.text)
        csvWriter.writerow([tweet.created_at,
                            create_url(tweet.id),
                            tweet.user.screen_name,
                            remove_linebreaks(tweet.text.encode('utf-8'))])

# rose quarter & @OregonDOT
for tweet in tweepy.Cursor(api.search, q="rose quarter", count=100,
                           lang="en",
                           since="2019-02-01").items():
    if re.search('@OregonDOT', tweet.text):
        print (tweet.created_at, tweet.text)
        csvWriter.writerow([tweet.created_at,
                            create_url(tweet.id),
                            tweet.user.screen_name,
                            remove_linebreaks(tweet.text.encode('utf-8'))])

# freeway expansion & @OregonDOT
for tweet in tweepy.Cursor(api.search, q="freeway expansion", count=100,
                           lang="en",
                           since="2019-02-01").items():
    if re.search('@OregonDOT', tweet.text):
        print (tweet.created_at, tweet.text)
        csvWriter.writerow([tweet.created_at,
                            create_url(tweet.id),
                            tweet.user.screen_name,
                            remove_linebreaks(tweet.text.encode('utf-8'))])

# portland & freeway expansion
for tweet in tweepy.Cursor(api.search, q="freeway expansion", count=100,
                           lang="en",
                           since="2019-02-01").items():
    if re.search('portland', tweet.text):
        print (tweet.created_at, tweet.text)
        csvWriter.writerow([tweet.created_at,
                            create_url(tweet.id),
                            tweet.user.screen_name,
                            remove_linebreaks(tweet.text.encode('utf-8'))])

# freeway widening & portland
for tweet in tweepy.Cursor(api.search, q="freeway widening", count=100,
                           lang="en",
                           since="2019-02-01").items():
    if re.search('portland', tweet.text):
        print (tweet.created_at, tweet.text)
        csvWriter.writerow([tweet.created_at,
                            create_url(tweet.id),
                            tweet.user.screen_name,
                            remove_linebreaks(tweet.text.encode('utf-8'))])
# freewayted hashtag
for tweet in tweepy.Cursor(api.search, q="#freewayted", count=100,
                           lang="en",
                           since="2019-02-01").items():
    print (tweet.created_at, tweet.text)
    csvWriter.writerow([tweet.created_at,
                        create_url(tweet.id),
                        tweet.user.screen_name,
                        remove_linebreaks(tweet.text.encode('utf-8'))])
