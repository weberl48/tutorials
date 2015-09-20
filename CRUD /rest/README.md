#What is a REST API?
- REST: Representational State Transfer
- lighter weight alternative to SOAP and WSDL XML-based API protocols.
- users a client-server model. server is an HTTP server and the client sends HTTP verbs (GET, POST,PUT,DELETE), a URL and URL-encoded variable parameters.
- URL describes the object to act upon and the server replies with a result code and JSON.
#CRUD to HTTP verbs
- POST: client wants to insert or create an object
- GET: client wants to read an object.
- PUT: client wants to update an object
- DELETE: client wants to delete and object.
#Creating the REST API
App: RSS Aggregator
Main Components:
  - REST API
  - Feed Grabber
User Requirements:
  - create account
  - subscribe/unsubscribe to feeds
  - read feed entries
  - mark feeds/entries as read or unread
Data Model Requirements:
  - Store user information in user accounts
  - Track RSS feeds that need to be monitored
  - Pull feed entries into the database
  - Track user feed subscriptions
  - Track which feed entry a user has already read
Collections:
- Feed Collection
- Feed Entry Collection
- User Collection
- User-feed-entry mapping Collection
##Feed Collection
- there is mapping in mongo from most Relational DB concepts.
- database contains one or more collections
- collections hold documents
  - document similar to a row in a relational table
  - documents do not follow a fixed schema (pre-degined columns of values)
RSS Feed Model:
```js
        {
        "_id": ObjectId("523b1153a2aa6a3233a913f8"),
        "requiresAuthentication": false,
        "modifiedDate": ISODate("2014-08-29T17:40:22Z"),
        "permanentlyRemoved": false,
        "feedURL": "http://feeds.feedburner.com/eater/nyc",
        "title": "Eater NY",
        "bozoBitSet": false,
        "enabled": true,
        "etag": "4bL78iLSZud2iXd/vd10mYC32BE",
        "link": "http://ny.eater.com/",
        "permanentRedirectURL": null,
        "description": "The New York City Restaurant, Bar, and Nightlife Blog"
}
```
- id is the primary key in a mongo document
  - guarantee that within a collection, a value is unique.
##Feed Entry Collection
```js
      {
          "_id": ObjectId("523b1153a2aa6a3233a91412"),
          "description": "Buzzfeed asked a bunch of people...",
          "title": "Cronut Mania: Buzzfeed asked a bunch of people...",
          "summary": "Buzzfeed asked a bunch of people that were...",
          "content": [{
              "base": "http://ny.eater.com/",
              "type": "text/html",
              "value": ”LOTS OF HTML HERE ",
              "language": "en"
          }],
          "entryID": "tag:ny.eater.com,2013://4.560508",
          "publishedDate": ISODate("2013-09-17T20:45:20Z"),
          "link": "http://ny.eater.com/archives/2013/09/cronut_mania_41.php",
          "feedID": ObjectId("523b1153a2aa6a3233a913f8")
      }
```
- content filed stores an array holding a document.
  - mongo allows sub-document storage in this way
- feedId the ObjectID of the feed document associated with the feed entry
##User Collection
```js
        {
         	"_id" : ObjectId("54ad6c3ae764de42070b27b1"),
         	"active" : true,
         	"email" : "testuser1@example.com",
         	"firstName" : "Test",
         	"lastName" : "User1",
         	"sp_api_key_id" : "6YQB0A8VXM0X8RVDPPLRHBI7J",
         	"sp_api_key_secret" : "veBw/YFx56Dl0bbiVEpvbjF",
         	"lastLogin" : ISODate("2015-01-07T17:26:18.996Z"),
         	"created" : ISODate("2015-01-07T17:26:18.995Z"),
         	"subs" : [ ObjectId("523b1153a2aa6a3233a913f8"),
                                        ObjectId("54b563c3a50a190b50f4d63b") ],
        }
```
##User-Feed-Entry Mapping Collection
```js
        {
         	"_id" : ObjectId("523b2fcc054b1b8c579bdb82"),
         	"read" : true,
         	"user_id" : ObjectId("54ad6c3ae764de42070b27b1"),
         	"feed_entry_id" : ObjectId("523b1153a2aa6a3233a91412"),
         	"feed_id" : ObjectId("523b1153a2aa6a3233a913f8")
        }
```

##User Requirements Mapped to HTTP routes and verbs

<table class="table" style="margin-top: 0px">
    <thead>
        <tr>
            <th>Route</th>
            <th>Verb</th>
            <th>Description</th>
            <th>Variables</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>/user/enroll</td>
            <td>POST</td>
            <td>Register a new user</td>
            <td>
firstName<br>
lastName<br>
email<br>
password<br></td>
        </tr>
    </tbody>
 <tbody>
        <tr>
            <td>/user/resetPassword</td>
            <td>PUT</td>
            <td>Password Reset</td>
            <td>email</td>
        </tr>
    </tbody>
 <tbody>
        <tr>
            <td>/feeds</td>
            <td>GET</td>
            <td>Get feed subscriptions for each user with description and unread count</td>
            <td></td>
        </tr>
    </tbody>
 <tbody>
        <tr>
            <td>/feeds/subscribe</td>
            <td>PUT</td>
            <td>Subscribe to a new feed</td>
            <td>feedURL</td>
        </tr>
    </tbody>
 <tbody>
        <tr>
            <td>/feeds/entries</td>
            <td>GET</td>
            <td>Get all entries for feeds the user is subscribed to</td>
            <td></td>
        </tr>
    </tbody>
 <tbody>
        <tr>
            <td>/feeds/&lt;feedid&gt;/entries</td>
            <td>GET</td>
            <td>Get all entries for a specific feed</td>
            <td></td>
        </tr>
    </tbody>
 <tbody>
        <tr>
            <td>/feeds/&lt;feedid&gt;</td>
            <td>PUT</td>
            <td>Mark all entries for a specific feed as read or unread</td>
            <td>read = &lt;true | false&gt;</td>
        </tr>
    </tbody>
 <tbody>
        <tr>
            <td>/feeds/&lt;feedid&gt;/entries/&lt;entryid&gt;</td>
            <td>PUT</td>
            <td>Mark a specific entry as either read or unread</td>
            <td>read = &lt;true | false&gt;</td>
        </tr>
    </tbody>
 <tbody>
        <tr>
            <td>/feeds/&lt;feedid&gt;</td>
            <td>DELETE</td>
            <td>Unsubscribe from this particular feed</td>
            <td></td>
        </tr>
    </tbody>
</table>
