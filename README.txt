After trying many of the Magic: The Gathering life counters for iPhone, I discovered that they're all kind of ugly and not very nice to use. The one I liked most was "20 Life" (definitely not ugly), however it was buggy and hard to use in some ways.

So, here is my life counter app.

Quick User Guide:
-------------------------------------------------------------
1. Press + or - to change life total
2. Swipe vertically to change life total quickly
3. Swipe horizontally to change color
4. Press "D20" to roll a D20
5. Press the refresh button to reset life totals
6. Rotate the phone for alternate view. - Portrait works best for Duel and 2HG - Landscape works best for 3 player and Star

I can't submit it to the App Store as I don't have my own apple developer account, and can't justify spending $99USD to give something away for free. If anyone else has an app store dev account and wants to take the source code and publish this, feel free. I only ask that you publish it for free, and let me know that you've done so.


Technical Notes:
-------------------------------------------------------------
This app is written entirely in Swift 3, so it requires Xcode 8 or newer to compile.

The way the app does layout is made INCREDIBLY more complicated than it should be, because
iOS can't rotate a view with auto layout. As such, if you read the code a lot of it will look horrible and like it's doing multiple pieces of similar work that shouldn't be neccessary. Unfortunately, it is

Originally the app would simply create instances of PlayerViewController and rotate the entire PVC,
which was fine so long as you only rotate by 180 degrees. Rotation of a non-square view by 90 degrees causes part of the background to appear as white bars and part to be clipped

What happens is this:
- AutoLayout sizes the container to 4 x 2
- View renders at 4 x 2 resolution (so the background is 4 wide and 2 high)
- View is rotated by 90 degrees, so is now 2 x 4 (2 wide and 4 high)
- 2 x 4 View is placed in the center of a 4 x 2 container
- The rendered view is only 2 wide, so there's whitespace of 1 on either side
- The container is only 2 high, so there's clipped content of 1 on the top/bottom

To work around this, the app ONLY rotates text views. All items have custom layout to place things in the place you'd expect them to be... if rotating the entire container actually worked.
Likewise gesture recognizers all adjust their maths to pretend as if the entire view was rotated (but it's not)

The upside is that this project has been an *incredibly* good learning excercise for auto layout, ViewController containers, and so forth.
