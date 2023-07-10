# The Binding of Isaac: Repentance Floor Navigation Strategy for Speedrunning

<br>

## Intro

In The Binding of Isaac: Rebirth, floors are randomly generated, and the goal of a speedrun is to get to the boss of the floor as quickly as possible. From the starting room, the boss is equally likely to be in any of the four directions. Thus, newer speedrunners often assume that there is no strategy at all to picking a direction. This is false.

<br>

## General strategy 1: Top/down over left/right

This is the most important strategy in this document. From the center of a room, it is faster to reach the top/bottom door than the left/right door. It is trivial to confirm this yourself with a timer. Thus, if a path is equally likely to be to the top/bottom or left/right, you should always go top/bottom. Many bad speedrunners make this mistake constantly, losing time every time they do it.

Credit goes to Krakenos for discovering this strategy.

<br>

## General strategy 2: Assume no loops

Only a small subset of floors are "looping", which means that branching paths will almost never connect to each other. Thus, it is sometimes possible to identify a dead end based on currently known map information.

For example:

```
| . . . . . . . |
| . O S O O O . |
| . . X . O . . |
| . . . X C X . |
| . . . . X . . |
| . . . . . . . |
```

- . - Nothing
- S - The starting room on the floor
- O - An explored room
- X - An unexplored room
- C - The current location

From this map, we can see that from our current location, going left would only be a viable path if it was a looping floor. And since almost no floors are looping, it is almost certainly a dead-end, so either down or right should be chosen.

<br>

## General strategy 3: Avoid 1x1 narrow rooms

We can perform room analysis using Basement Renovator to derive the percentage rate of narrow rooms. This is left as an exercise to the reader.

It is not known what the exact probability of an arbitrary room along your path being a Mini-boss Room or a Sacrifice Room. However, due to the way the floor generation algorithm works, there is often a Mini-boss Room or a Sacrifice Room on the floor. Since the narrow percentage is so skewed in favor of these special rooms, the correct strategy is assumed to be to always avoid narrow rooms, as they will more likely be a Mini-boss Room or a Sacrifice Room than a "normal" room, and will thus be a dead end.

Note that it is assumed to be better to check a narrow 1x1 room than to backtrack further in the floor.

Credit goes to me for discovering this strategy.

<br>

## General strategy 4: "Moon strats"

"Moon strats" is a term used to describe a strategy where you can avoid clearing rooms by double-bombing through a Secret Room. It is usually a good idea to try for moon strats, because they can sometimes skip huge amounts of the floor. Even if you only have 1 bomb, you can still try for moon strats, as there is a high probability of fighting Greed, which will automatically open all of the exits. Failing that, you can also find free bomb drops inside some Secret Rooms.

Moon strats are quite obvious to do if you have an item such as X-Ray Vision, Spelunker Hat, or Dog Tooth, as they will reveal where the Secret Room is. Other times, you will have Ipecac or Dr. Fetus, and will be bombing suspicious looking walls in the middle of clearing the room or as you pass by them. However, most of the time, you will not have any of these items.

Often times you can "naturally" identify that a secret room is attached to the current room when the room has an extra exit that is unused. This is because it is unlikely for the floor generation algorithm to choose a room with the "wrong" number of exits. Even if you choose not to waste a bomb on a secret room initially, you may hit a dead end and have to backtrack through the same room. In this case, you almost always want to try for moon strats.

For example:

```
| . . . . . . . . . . |
| . O O O O O X ? . . |
| . O . . . C T ? . . |
| X S X . . O . . . . |
| . X . . . O . . . . |
| . . . . . . . . . . |
```

- . - Nothing
- S - The starting room on the floor
- O - An explored room
- X - An unexplored room
- C - The current location
- T - The Secret Room
- ? - A hypothetical room that may or may not exist

From this map, imagine that we are coming back from the dead end in the bottom right. We know that the floor has a high probability to "wrap around" to the other end of the Secret Room. Thus, using moon strats here would save backtracking through 1 room + clearing through 1 room.

The term "moon strats" was coined by speedrunners back around 2013 before the release of Rebirth.

<br>

## Compass strategy 1: Go towards the special rooms

Often times, special rooms will be attached to (or close to) the main linear path of a floor. Thus, you will usually want to go towards the special rooms and NOT towards the boss.

For example, if the boss is directly to the right but you see that the shop, Treasure Room, and Challenge Room are all below you, then you can tell that going right will most likely be a dead-end; the floor will go down and around and back up towards the boss.

<br> 

## Compass strategy 2: Avoid short paths

The average amount of rooms on each floor increases linearly for each floor. This means that the average size of Basement 1 will be a lot smaller than the average size of the Chest. Thus, after doing many runs, you can get a feel for the average size of each floor.

If the compass reveals that the boss is on a path that is shorter than the average size of the floor, then it is probably NOT the way. Always go towards the next-most-likely direction.

<br>

## Treasure Map strategy 1: Go towards the furthest room

The boss is most likely to be in the room that is the furthest number of rooms away from the starting room. Note that for the purposes of this calculation, the various big rooms should be counted the same as 1x1 rooms.

<br>

## Treasure Map strategy 2: 2x1 Boss Rooms

The boss is almost always a 1x1 room. Thus, if you can see that the longest path ends in a non 1x1 room, then the boss is NOT on the longest path.

The major exception to this is on Womb 1; a common boss here is Fred, who lives in a 2x1 room. So on Womb 1 you should want to go to a longest path that ends in a 2x1.

Another exception to this is when the boss is a Double Trouble, which can happen on floors Caves 1, Caves 2, Depths 1, and Womb 1. Double Troubles are extremely rare, so you should always assume that the floor is not a Double Trouble.

<br>

## Blue Map strategy 1: Super Secret Room

On most floors, the Super Secret Room is close to the boss. Thus, you should generally go towards that. Unfortunately, this strategy only has around a 75% chance of working.

Sometimes, you can tell that the Super Secret room is in the wrong direction because it is extremely close to the starting room. In these situations, you will want to go towards the (normal) Secret room.

<br>

## Further information: Big rooms vs small rooms

Research has been performed to try and answer the question of whether a big room is more likely to be the way towards the boss. One million floor layouts were tested using the following room weights:

Small room strategy choosing priority:

```
{RoomShape.ROOMSHAPE_1x1, 2},
{RoomShape.ROOMSHAPE_1x2, 4},
{RoomShape.ROOMSHAPE_2x1, 4},
{RoomShape.ROOMSHAPE_2x2, 6},
{RoomShape.ROOMSHAPE_IH,  1},
{RoomShape.ROOMSHAPE_IIH, 3},
{RoomShape.ROOMSHAPE_IIV, 3},
{RoomShape.ROOMSHAPE_IV,  1},
{RoomShape.ROOMSHAPE_LBL, 5},
{RoomShape.ROOMSHAPE_LBR, 5},
{RoomShape.ROOMSHAPE_LTL, 5},
{RoomShape.ROOMSHAPE_LTR, 5},
```

Big room strategy choosing priority:

```
{RoomShape.ROOMSHAPE_1x1, 5},
{RoomShape.ROOMSHAPE_1x2, 3},
{RoomShape.ROOMSHAPE_2x1, 3},
{RoomShape.ROOMSHAPE_2x2, 1},
{RoomShape.ROOMSHAPE_IH,  6},
{RoomShape.ROOMSHAPE_IIH, 4},
{RoomShape.ROOMSHAPE_IIV, 4},
{RoomShape.ROOMSHAPE_IV,  6},
{RoomShape.ROOMSHAPE_LBL, 2},
{RoomShape.ROOMSHAPE_LBR, 2},
{RoomShape.ROOMSHAPE_LTL, 2},
{RoomShape.ROOMSHAPE_LTR, 2},
```

Clearing weight (to signify that it takes twice as long to clear a 2x2 room as it does a 1x1 room):

```
{RoomShape.ROOMSHAPE_1x1, 1f},
{RoomShape.ROOMSHAPE_1x2, 1.5f},
{RoomShape.ROOMSHAPE_2x1, 1.5f},
{RoomShape.ROOMSHAPE_2x2, 2f},
{RoomShape.ROOMSHAPE_IH,  0.75},
{RoomShape.ROOMSHAPE_IIH, 1f},
{RoomShape.ROOMSHAPE_IIV, 1f},
{RoomShape.ROOMSHAPE_IV,  0.75f},
{RoomShape.ROOMSHAPE_LBL, 1.75f},
{RoomShape.ROOMSHAPE_LBR, 1.75f},
{RoomShape.ROOMSHAPE_LTL, 1.75f},
{RoomShape.ROOMSHAPE_LTR, 1.75f},
```

This is the result: http://i.imgur.com/88koG60.png

Thus, there is no tangible difference between small and big rooms. However, this is only an estimation, so expert players may want to use their best judgement to choose their strategy based on:
1) the expected difficulty of the specific room type of the specific floor type that they are on
2) whether or not they are at the beginning or end of the floor

Credit goes to blcd (Blade) for programming the floor tester to derive this data.
