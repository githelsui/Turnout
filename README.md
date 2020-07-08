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
    * Users can fetch data on voting procedures, voting locations/dates with this [API](https://developers.google.com/civic-information).
    * Depending on user's zip code, fetch data (candidate, party, past projects, etc) on state, municipal, national gov. elections with this [API](https://www.democracy.works/elections-api) 
    * Embed a Calendar from the open-source external library FSCalendar that includes the upcoming election dates for that zipcode 

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
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
