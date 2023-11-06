# EssentialFeed

Narrative #1
As an online customer
I want the app to automatically load my latest image feed
So I can always enjoy the newest images of my friends
Scenarios (Acceptance criteria)
Given the customer has connectivity
 When the customer requests to see their feed
 Then the app should display the latest feed from remote
  And replace the cache with the new feed

[![CI-iOS](https://github.com/Aj281193/EssentialFeed/actions/workflows/CI-iOS.yml/badge.svg)](https://github.com/Aj281193/EssentialFeed/actions/workflows/CI-iOS.yml)
[![CI-macOS](https://github.com/Aj281193/EssentialFeed/actions/workflows/CI-macOS.yml/badge.svg)](https://github.com/Aj281193/EssentialFeed/actions/workflows/CI-macOS.yml)

 ### Narrative #2

As an offline customer
I want the app to show the latest saved version of my image feed
So I can always enjoy images of my friends


#### Scenarios (Acceptance criteria)

```
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is less than seven days old
  When the customer requests to see the feed
  Then the app should display the latest feed saved
 
 
Given the customer doesn't have connectivity
  And there’s a cached version of the feed
  And the cache is seven days old or more
  When the customer requests to see the feed
  Then the app should display an error message
  
Given the customer doesn't have connectivity
  And the cache is empty
  When the customer requests to see the feed
  Then the app should display an error message
```

## Use Cases

### Load Feed From Remote Use Case

#### Data:
- URL
#### Primary course (happy path):
1. Execute "Load image Feed" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System creates image feed from valid data.
5. System delivers image feed.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.

### Load Feed Fallback (Cache) Use Case

#### Data:
- Max age


### Load Feed From Cache Use Case

#### Primary course:
1. Execute "Load Image Feed" command with above data.
2. System fetches feed data from cache.
3. System validates cache age.
3. System validates cache is less than seven days old.
4. System creates image feed from cached data.
5. System delivers image feed.

#### Error course (sad path):
1. System delivers error.

#### Expired cache course (sad path): 
1. System deletes cache.
2. System delivers no feed images.

#### Empty cache course (sad path): 
1. System delivers no feed images.


### Cache Feed Use Case

#### Data:
- Image Feed

#### Primary course (happy path):
1. Execute "Save Image Feed" command with above data.
2. System deletes old cache data.
3. System encodes image feed.
4. System timestamps the new cache.
5. System saves new cache data.
6. System delivers success message.

#### Deleting error course (sad path):
1. System delivers error.

#### Saving error course (sad path):
1. System delivers error.


## Flowchart




## CodableFeedStore UseCase
✅ Retrieve
    ✅ Empty cache returns empty
    ✅ Empty cache twice returns empty (no side-effects)
    ✅ Non-empty cache returns data
    ✅ Non-empty cache twice returns same data (no side-effects)
    ✅ Error returns error (if applicable, e.g., invalid data)
    ✅ Error twice returns same error (if applicable, e.g., invalid data)
✅ Insert
    ✅ To empty cache stores data
    ✅ To non-empty cache overrides previous data with new data
    ✅ Error (if applicable, e.g., no write permission)
✅ Delete
    ✅ Empty cache does nothing (cache stays empty and does not fail)
    ✅ Non-empty cache leaves cache empty
    ✅ Error (if applicable, e.g., no delete permission)
- Side-effects must run serially to avoid race-conditions


UX goals for the Feed UI experience
[✅] Load feed automatically when view is presented
[✅] Allow customer to manually reload feed (pull to refresh)
[✅] Show a loading indicator while loading feed
[✅] Render all loaded feed items (location, image, description)
[✅] Image loading experience
    [✅] Load when image view is visible (on screen)
    [✅] Cancel when image view is out of screen
    [✅] Show a loading indicator while loading image (shimmer)
    [✅] Option to retry on image download error
    [✅] Preload when image view is near visible

### Load Feed Image Data From Remote Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System downloads data from the URL.
3. System validates downloaded data.
4. System delivers image data.

#### Cancel course:
1. System does not deliver image data nor error.

#### Invalid data – error course (sad path):
1. System delivers invalid data error.

#### No connectivity – error course (sad path):
1. System delivers connectivity error.


### Load Feed Image Data From Cache Use Case

#### Data:
- URL

#### Primary course (happy path):
1. Execute "Load Image Data" command with above data.
2. System retrieves data from the cache.
3. System delivers cached image data.

#### Cancel course:
1. System does not deliver image data nor error.

#### Retrieval error course (sad path):
1. System delivers error.

#### Empty cache course (sad path):
1. System delivers no found error.
