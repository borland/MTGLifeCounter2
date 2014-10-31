After trying many of the Magic: The Gathering life counters for iPhone, I discovered that they're all kind of ugly and not very nice to use. The one I liked most was "20 Life" (definitely not ugly), however it was buggy and hard to use in some ways.

So, here is my life counter app.


Quick User Guide:
-------------------------------------------------------------
1. Press + or - to change life total
2. Swipe vertically to change life total quickly
3. Swipe horizontally to change color
4. Press "D20" to roll a D20
5. Press the refresh button to reset life totals
6. Rotate the phone for alternate view. - Portrait works best for Duel and 2HG - Landscape works best for 3 player

I can't submit it to the App Store as I don't have my own apple developer account, and can't justify spending $99USD to give something away for free. If anyone else has an app store dev account and wants to take the source code and publish this, feel free. I only ask that you publish it for free, and let me know that you've done so.


Technical Notes:
-------------------------------------------------------------
This app is written entirely in Swift, so it requires Xcode 6 or newer to compile.
I've tested it against iOS 7 and 8.

I originally wrote this app in Objective-C, then ported it to swift as a learning excercise. Since porting, I've made numerous enhancements and fixes.
The original Objective-C app was a "my first app" and was also a learning excercise. Both apps were developed under tight time constraints and for my own personal use only.
As such, the following attributes of "professional software" are missing.

- Design documentation (The app is fairly simple)
- Architecture (see above)

- Good development practices such as separation of concerns, cohesion, etc. (Speed of implementation trumps everything when you have no time)
- Unit tests (as above)
- Logging and diagnostics (as above)
