# Jamlog

Explain jam, theme, and wildcards

## Day 1 - Idea

After theme announce - a lot of Googling.  Link to tooth demons, faust woodblocks, dataisbeautiful.  Had some ideas like maybe enemy names would be procedurally generated from these two word lists but I realised I was having a fun manually creating the names so thought that I should just make that the game.  Then to make difficulty ramp had idea of swapping the letters as just typing two words isnt really a game.  Everything was still just ideas written down on paper - went to bed and slept on it.

## Day 2 - Proof of Concept

Made a basic project in godot to show two lists of words, Show 202202111239.png, felt good to me.  sent screenshots to a few people to get some early feedback on idea.  took a few goes at explaining as difficult.  Got some nice feeback so I expanded on the example to have more word scramble curse types and a way to see them on the screen.  Got general UI setup.

## Day 3 - Game Loop

find screenshot of this section of game So far you could just play one round and curses were hardcoded in code.  Added a proper game loop by having timed rounds where you would have progressively more rules the more you complete. Toyed with having 1 round constonant swap, 1 vowel then 3rd combined to make diffuculty ram slower but I preferred the shorter and harder game.

## Day 4 - Theming

Time to add art to game, realised I have negative skill but I remembered the woodblock puzzles so though it would be easy to replicate tat art style  Also was outside of my skills so I just used the magic wand and to remove characters from my favourite one, fixed the missing parts of the backgrounds manualluy .,I drae a low res devil in the same style as original and just placed him in the middel.  Had trouble witht the head/facial expressions so just left as palceholder to be replaced later (asked for help).  

Now background and character art was done a really big boost was changing default UI theme in Godot to match.  Suprisinly easy but makes huge difference.  choosing a font is huge aswell and it was an eady to choice to find a medieval style font to match the background.  Although it was hard to find one that was super readable but I thought I made a good choice.

Game would end after banishing three demons so I added a requirement to banish multiple demons per round - made the game easier by easing player into it at the expense of lasting a little longer, and making made final round harder.

## Day 5 - Animation and Refactoring

So far all the code was mainly in one big horrible file and a lot of little bugs were building up in the codebase so i made a start in refactoring the code to make it easier to fix the bugs and add more features.

Also added some basic animations as I was tidying so it felt like still making progress and added the beginnings of the audio system as animation and audio feel pretty linked so made sense to add this at the same time.  Wasn't sure what the audio would be so it was still silent but the systems were in place just waiting on files.

## Day 6 - Bug Fixes and Cheat Mode

A little bit more refacoring was needed today and then I solved all of the bugs that I could find.  Was much easier now that the code was tidy.  Cheat mode added to help when testing allowing me to zoom through the levels to test weird bits manually.

## Day 7 - Audio & Polish

Final day of coding work.  Basically got the final UI done foer trh game, lots of testing.  At one point I removed the audio fomr the game because I couldnty think of what the game should sound like but my brother convinced me to add it back and to go with a medieval tine so added back in.  Glad he did beacuse it adds a lot.


## Day 10 - Final Art, Content then Submission

Tosolve my drawing issue, I asked sister if she could draw the demon head.  Added in and looks so much better than the big square one or anything else I could have done.  I also sat and completed the word list.  Then it was just the case of writing the description, controls, credits,.  taking screenshots, styling itch page, exporting upload.  cheated beacuse description controls and credits are all out of game right now.  but i like how simple it makes it.

## Reviews

feels good to get feedback, very positive.  font being hard to read and the game being difficult main two criticisms.  a lot said fun and challenign though so nice.

## Rating Games

managed to play most of the other jam games.  relly interesting to do it and see the positives in every game - lots of great work.. lied games that were similar to mine as i could compare how they did certain things.

checking feeback on other games good too.  nice to see everyone is very positive

## Worth it?

yes.  before jam i had many half finished projects and a load of untested ideas but a bit of pressure goes a long way.  making you going through whole cycle is good too because i had never exported, added proper audio, uploaded to itch so i got to experience more of the game dev cycle.  getting some guarantted feedback ont eh game is invaluable too.
