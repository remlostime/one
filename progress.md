# Milestone-1
> Estimated Time: 28.5 days, Mar 11 Done
> Actual Time: Feb 2 - Feb 23, 2017, 22 days, Awesome work!

## Improvements
### Feature - 4.5 days
* Search tab - 2 days
	* Hook Discovery Post collection view
	* Fix Search bar UI
* Notification tab - 1 day
	* Cell tap action - navigate to user, post, comments
	* User name label action - navigate to profile page
	* fetch user profile image
* Notification Popup Icon Feature - 1 day
	* If there is new notification, we show a NUX UI
	* Design the icon
* Add how many likes for this post - 0.5 day

### UI - 4 days
* Add App Title on Navigation Bar - 0.5 day
* Login Screen Enhance - 1 day
	* Button and background
* Remove Tab bar text - 0.5 day
* Post Bar - 0.5 day
	* Add post button on the top right
	* Add placeholder icon for post image view
* Add Settings button on top right, move log out function inside settings - 1 day
* Profile Page Enhance - 0.5 day
	* Make the profile image in profile tab smaller
	* Make the posts, follower, following font spacing equal

### Refactor - 5.5 days
* Comments VC - 0.5 day
	* Add uuid and postID for comment model
* Create alert helper class - 1 day
* Refactor FollowVC and FollowingVC - 2 days
* Refactor GuestVC and HomeVC, they should share common codes - 2 days

### Network - 4 days
* Move a network request helper class - 2 day
 - Replace all server username and id to uuid - 2 days

### Icon - 3 days
* Feed Icon - 0.5 day
* log out icon - 0.5 day
* Edit Profile Page all icons - 1 day
* Create Icon for 'delete', 'reply', 'complain' buttons - 0.5 day
* Design App icon - 0.5 day

### Others - 4 days
* Setup Travis - 1 day
*  Private, fileprivate vars and func - 1 day
* Improve Readme - 1 day
* Replace print error with error library - 1 day

### Bug - 3.5 days
* [53][1] - 0.5 day
	* iOS - fix comment navigation bug
	* iOS - Delete hashtag function
* Replace textField with textView in the commentVC - 1 day
* Collection View in Profile Page is flushing - 0.5 day
* Fix edit user page error - 0.5 day
*  Fix all optional, guard let, force unwrapped issue - 1 day

## Timeline
![M1 Timeline](https://github.com/remlostime/one/blob/master/m1/m1-timeline.jpg)

# Milestone-0
> **Done** : Dec 19, 2016  - Jan 31, 2017
> 44 days

* New user sign up, login, reset password
* User profile and picture gallery
* Followers and following
* Edit user information
* Post images
* Post page
* Comments
* Hashtags and mentions
* Feed page
* Search page for users search and popular posts
* Notification of likes, comments, follows and mentions

## [Demo Video][3]

## Screenshot
![Profile][image-1]

![Post][image-2]

## Timeline
![timeline][image-3]

[1]:	https://github.com/remlostime/one/issues/53
[2]:	https://github.com/remlostime/one/blob/master/m1/m1-timeline.png
[3]:	https://www.dropbox.com/sc/ah188uqe2zzetdp/AAD3rS-hC2c1pT1PTuUf3UHQa

[image-1]:	https://github.com/remlostime/one/blob/master/m0/one-profile.png
[image-2]:	https://github.com/remlostime/one/blob/master/m0/one-post.png
[image-3]:	https://github.com/remlostime/one/blob/master/m0/timeline-m0.png
