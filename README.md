Original App Design Project - Githel Suico
===

# Turnout 

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
Turnout is an iOS mobile app designed to bring light to its users' civil liberties and rights as a voter. Voter suppression and the lack of voter turnout has been a pressing issue throughout election periods, therefore Turnout serves as a one-stop point to provide information on: voter registration steps, [polling station locations/dates]((https://www.democracy.works/elections-api)), [details on running candidates, and data (party, past projects, etc) on your state, municipal, national government officials](https://developers.google.com/civic-information). The main functionality is a reporting system, allowing users to post any instances of voter suppression (station location/date changes, longer lines, etc) to a public livefeed.

### App Evaluation
- **Category:** News
- **Mobile:** On the go aspect allows users to report an incident immediately and access information anywhere whether at a polling station, registering to vote, anywhere.
- **Story:** Recent elections have seen a decrease in millenial political engagement, therefore Turnout tackles voter suppression and the decreasing turnout rate by providing information on voter registration, ballot access, and candidate details. With Turnout, users can report false information about voting procedures/candidates/etc
- **Market:** First-time voters, those who want to learn more about how they can be more involved, voters in general
- **Habit:** Users would often use this app to inform themselves of their civic rights, not just during election seasons. 
- **Scope:** Possible in four weeks. MVP is fetching data on election dates/locations and candidates from the API's as well as creating a User login through the Facebook SDK, and the ability to post. UI consists of several table view cells.
### App Requirements
- Multiple views
- Interacts with a database (e.g. Parse)
- Log in/log out of your app as a user
- Sign up with a new user profile
- Camera to take a picture (users can post their incidents with pictures)
- Integrates with a SDK (Facebook SDK)
- App contains at least one more complex algorithm (?)
    - [Data Sharding](https://blog.yugabyte.com/how-data-sharding-works-in-a-distributed-sql-database/)
- Gesture recognizers
- Animation (e.g. fade in/out, e.g. animating a view growing and shrinking)
- Incorporates an external library to add visual polish

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* Users can login/sign up through Facebook SDK, take into account the user's zip code if new user
* Users can post incidents to the livefeed (posts incorporate camera and photos) and save to database
* Livefeed Section: 
    * Users can view the posted reports of other User's (incorporate "complex" algorithm with how to sort this data)
    * Users can like a report
* Profile Section:
    * Users can view their own past reports
    * Users can save details from the Information Section to view on their profile
* Information Section: 
    * 1 calendar + 4 different screens depending on [API endpoint](https://www.democracy.works/elections-api): Voter Guide, Elections, Representatives, and Bills/Propositions
    *  Voter Guide: directs User to Vote.org's links for voter registration 
    *  Elections: presents list of upcoming elections with their dates + locations for polling station. Also presents running candidates
    *  Representatives: list of representatives based on zipcod. Tapping on details leads to info on rep + bills they cosponsor
    *  Bills: list of bills and tapping on cell redirects to its details + representatives cosponsoring it
    * Embed a Calendar from open-source external library FSCalendar that includes the upcoming election dates (based on the Elections Screen)

**Optional Nice-to-have Stories**
* The ability to share posts to other social media services
* Users can comment on a post
* Posting videos and using a media player to view them
* For each government candidate, users can leave a comment on their page, almost like a reviews section
* A user can save another users' posts in their Profile Section
* The ability for a user to change their zip code (Settings Page)

### 2. Screen Archetypes

* Login/Sign Up
   * Users can login/sign up through Facebook SDK\
* Onboarding
    * First time user signs up, redirect them to modally presented view that requires a zipcode.
* Stream
   * Information Section
   * Livefeed Section of posted reports
* Creation
    * Users can post incidents to the livefeed (posts incorporate camera and photos) and save to database
* Detail 
    * Each posts has details a user can view including texts and photo
* Profile
    * Users can view their own past reports
    * Users can save details from the Information Section to view on their profile
### 3. Navigation

**Tab Navigation** (Tab to Screen)

* Livefeed Section
* Profile Section
* Information Section

**Flow Navigation** (Screen to Screen)

* Livefeed Section
    => Each post leads to a Detail Screen 
    => Top right navigation button leads to Creation Screen
* Profile Section
    => Each post leads to a Detail Screen
    => Top right navigation button leads to Creation Screen
* Information Section
    => Each post leads to a Detail Screen

## Wireframes
### Hand Sketched Wire Frames
<img src="https://i.imgur.com/h4roBlg.jpg" width=800>

### Digital Wireframes & Mockups | [Figma Wireframes](https://www.figma.com/file/dfhaJO78QqZBOufKvo3DqC/Turnout-iOS-App?node-id=0%3A1)
<img src="https://i.imgur.com/sacLvcb.png" width=150>
<img src="https://i.imgur.com/5zoS3lt.png" width=150>
<img src="https://i.imgur.com/g5PkO9m.png" width=150>
<img src="https://i.imgur.com/VvY2rmH.png" width=150> 
<img src="https://i.imgur.com/FBg8hMv.png" width=150>
<img src="https://i.imgur.com/zONOosK.png" width=150>
<img src="https://i.imgur.com/8biwYF3.png" width=150>
<img src="https://i.imgur.com/IpxH5JU.png" width=150>

### Interactive Prototype | [Figma Prototype](https://www.figma.com/proto/dfhaJO78QqZBOufKvo3DqC/Turnout-iOS-App?node-id=4%3A63&scaling=scale-down)
<img src="https://media1.giphy.com/media/kfjnD2d7tqF0dxQUsH/giphy.gif" width=250>
<img src="https://media2.giphy.com/media/dt5wf69i8IXkUD2qBn/giphy.gif" width=250><br>
<img src="https://media0.giphy.com/media/dWHY61CFCgfYfM6lmP/giphy.gif" width=250>
<img src="https://media1.giphy.com/media/f5Mn72etEsTtTv6dno/giphy.gif" width=250>

## Schema 

### Models (Parse Classes + NSObjects)

#### User
| Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the |
   | username      | String   | name for the user |
   | zipcode        | Pointer to Zipcode| Zipcode of post's user |
   
   
#### Post
| Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for the user post (default field) |
   | author        | Pointer to User| image author |
   | image         | File     | image attached to user posts |
   | status       | String   | text/status by author |
   | likesCount    | Number   | number of likes for the post |
   | likedByUser    | Boolean   | whether current user liked the post |
   | createdAt     | DateTime | date when post is created (default field) |
   | updatedAt     | DateTime | date when post is last updated (default field) |
   | zipcode        | Pointer to Zipcode| Zipcode of post's user |


#### Reference (Current user's bookmarked data from API)
- only save API data into Parse db when user adds it to bookmarks/saved
| Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for reference |
   | tile      | String   | title for the reference fetched from the API endpoint |
   | info | String | List of strings for website urls |
   | photoUrl     | String | url of the fetched reference's image |
   | date | String | date of event if applicable |
   | location | String |location of event if applicable |
   | createdAt     | DateTime | date when post is created (default field) |
   | links | Array | List of strings for website urls |
   | supporters | Array | List of strings for website urls |
   | savedByUser     | Boolean   | whether current user has saved the reference |
   
- a different iteration
| Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for reference |
   | fetchedData      | Object   | NSDictionary of the fetched data from the API |
   | savers      | Array   | list of User objects that have bookmarked the reference |

#### Zipcode
| Property      | Type     | Description |
   | ------------- | -------- | ------------|
   | objectId      | String   | unique id for reference |
   | zipcode      | String   | current zipcode |
   | neighbors      | Array   | list of neighboring zipcodes |
   
## Networking

### List of network requests by screen (Parse DB)
 - Live Feed Screen
      - (Read/GET) Query all Posts sorted in weights of likesCount and zipcdoe
      - (Create/POST) Create a new like on a Post
      - (Delete) Delete existing like
- Creation Screen
    - (Create/POST) Create a new Post object
 - Index Screen
      - (Create/POST) Create a new Reference when user bookmarks a reference from the Index Screen
      - (Delete) When user unbookmarks a reference, remove user from array property and delete row if array count is now 0
- Profile Screen
     - (Read/GET) Query logged in User object
     - (Read/GET) Query all Posts where user is author
     - (Read/GET) Query all References where user is inside the savers property array

### Existing API Endpoints

##### Google Maps Geocoding API
- Base URL - [http://maps.googleapis.com/maps/api](http://maps.googleapis.com/maps/api) 

   HTTP Verb | Endpoint | Description
   ----------|----------|------------
    `GET`    | /geocode/json?address={zipcode} | get zipcode lat,lng coord from the  key 'location'
    
    
##### Google Civic Information API
- Base URL - [https://www.googleapis.com/civicinfo/v2](https://www.googleapis.com/civicinfo/v2)

   HTTP Verb | Endpoint | Description
   ----------|----------|------------
    `GET`    | /elections | List of available elections to query
    `GET`    | /voterinfo | Looks up information relevant to a voter based on the voter's registered address
    `GET`    | /representatives  | Looks up political geography and representative information for a single address
    
##### OpenFEC API
- Base URL - [https://api.open.fec.gov](https://api.open.fec.gov/)

   HTTP Verb | Endpoint | Description
   ----------|----------|------------
    `GET`    | /candidates/{candidate_id} | fetch most recent information about that candidate
    `GET`    | /candidates/{candidate_id}/history | fetches a candidate's characteristics over time
    
##### ProPublica Congress API
- Base URL - [https://api.propublica.org/congress/v1](https://api.propublica.org/congress/v1)

   HTTP Verb | Endpoint | Description
   ----------|----------|------------
    `GET`    | /{congress}/{chamber}/members.json | get a list of members of a particular chamber in a particular Congress
    `GET`    | /members/{member-id}/bills/{type}.json | get recent bills by a specific member
