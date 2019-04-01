from twarc import Twarc
import csv
import re


def create_url(tweet_id):
    return "http://www.twitter.com/statuses/" + str(tweet_id)


def remove_linebreaks(tweet_text):
    return re.sub(r'\n', ' ', tweet_text)


consumer_key = ''
consumer_secret = ''
access_token = ''
access_token_secret = ''

t = Twarc(consumer_key, consumer_secret, access_token, access_token_secret)

no_i5_tweets = []
for tweet in t.search("#NOI5RQX"):
    no_i5_tweets.append(tweet)

no_i5_replies = []


for tweet in no_i5_tweets[44:]:
    for reply in t.replies(tweet, recursive=False):
        no_i5_replies.append(reply)


# Open/Create a file to append data
csvFile = open('all_no_i5_replies.csv', 'a')

# Use csv Writer
csvWriter = csv.writer(csvFile)


for reply in no_i5_replies:
    csvWriter.writerow([
        reply['created_at'],
        create_url(reply['id']),
        reply['user']['screen_name'],
        remove_linebreaks(reply['full_text'].encode('utf-8')),
    ])
