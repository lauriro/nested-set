Nested set model example
========================


<pre>
15:21:34 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh

Nested set model example
========================

Commands are:
  init                          Create database
  add <parent_id> <name>        Add node to end
  addFirst <parent_id> <name>   Add node to beginning
  del <node_id>                 Remove node with childs
  delOne <node_id>              Remove only node and move childs under parent
  move <node_id> <parent_id>    Move node under new parent
  swap <node_id> <node_id>      Swap two node with childs
  order <node_id> <child_ids>   Sort childs
  path <node_id>                Print path
  childs <node_id>              Print childs
  leafs                         Print leafs
  rebuild                       Rebuild left and right indexes
  reset                         Delete database and init again

15:21:40 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh init
  1[  0]   1-12     |- root
  2[  1]   2-11        |- Eesti
  3[  2]   3-10           |- Harjumaa
  4[  3]   4-9               |- Tallinn
  5[  4]   5-8                  |- Kristiine
  6[  5]   6-7                     |- Tedre

15:22:06 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh add 5 'Käo'
  1[  0]   1-14     |- root
  2[  1]   2-13        |- Eesti
  3[  2]   3-12           |- Harjumaa
  4[  3]   4-11              |- Tallinn
  5[  4]   5-10                 |- Kristiine
  6[  5]   6-7                     |- Tedre
  7[  5]   8-9                     |- Käo

15:22:26 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh add 2 'Raplamaa'
  1[  0]   1-16     |- root
  2[  1]   2-15        |- Eesti
  3[  2]   3-12           |- Harjumaa
  4[  3]   4-11           |  |- Tallinn
  5[  4]   5-10           |     |- Kristiine
  6[  5]   6-7            |        |- Tedre
  7[  5]   8-9            |        |- Käo
  8[  2]  13-14           |- Raplamaa

15:22:33 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh add 8 'Rapla'
  1[  0]   1-18     |- root
  2[  1]   2-17        |- Eesti
  3[  2]   3-12           |- Harjumaa
  4[  3]   4-11           |  |- Tallinn
  5[  4]   5-10           |     |- Kristiine
  6[  5]   6-7            |        |- Tedre
  7[  5]   8-9            |        |- Käo
  8[  2]  13-16           |- Raplamaa
  9[  8]  14-15              |- Rapla

15:22:50 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh move 8 1
  1[  0]   1-18     |- root
  2[  1]   2-13        |- Eesti
  3[  2]   3-12        |  |- Harjumaa
  4[  3]   4-11        |     |- Tallinn
  5[  4]   5-10        |        |- Kristiine
  6[  5]   6-7         |           |- Tedre
  7[  5]   8-9         |           |- Käo
  8[  1]  14-17        |- Raplamaa
  9[  8]  15-16           |- Rapla

15:22:57 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh move 8 2
  1[  0]   1-18     |- root
  2[  1]   2-17        |- Eesti
  3[  2]   3-12           |- Harjumaa
  4[  3]   4-11           |  |- Tallinn
  5[  4]   5-10           |     |- Kristiine
  6[  5]   6-7            |        |- Tedre
  7[  5]   8-9            |        |- Käo
  8[  2]  13-16           |- Raplamaa
  9[  8]  14-15              |- Rapla

15:23:09 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh swap 3 8
  1[  0]   1-18     |- root
  2[  1]   2-17        |- Eesti
  8[  2]   3-6            |- Raplamaa
  9[  8]   4-5            |  |- Rapla
  3[  2]   7-16           |- Harjumaa
  4[  3]   8-15              |- Tallinn
  5[  4]   9-14                 |- Kristiine
  6[  5]  10-11                    |- Tedre
  7[  5]  12-13                    |- Käo

15:23:13 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh swap 3 8
  1[  0]   1-18     |- root
  2[  1]   2-17        |- Eesti
  3[  2]   3-12           |- Harjumaa
  4[  3]   4-11           |  |- Tallinn
  5[  4]   5-10           |     |- Kristiine
  6[  5]   6-7            |        |- Tedre
  7[  5]   8-9            |        |- Käo
  8[  2]  13-16           |- Raplamaa
  9[  8]  14-15              |- Rapla

15:23:36 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh path 8
  1[  0]   1-18     |- root
  2[  1]   2-17        |- Eesti
  8[  2]  13-16           |- Raplamaa

15:23:43 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh childs 8
  8[  2]  13-16     |- Raplamaa
  9[  8]  14-15        |- Rapla

15:23:53 Lauri@hp /code/kool/nested-set (master #)
$ ./nested-set.sh leafs
  6[  5]   6-7      |- Tedre
  7[  5]   8-9      |- Käo
  9[  8]  14-15     |- Rapla

11:15:16 Lauri@hp /code/repo/nested-set (master *)
$ ./nested-set.sh order 5 '7,6'
Swap  6 7
  1[  0]   1-18      |- root
  2[  1]   2-17         |- Eesti
  3[  2]   3-12            |- Harjumaa
  4[  3]   4-11            |  |- Tallinn
  5[  4]   5-10            |     |- Kristiine
  7[  5]   6-7             |        |- Käo
  6[  5]   8-9             |        |- Tedre
  8[  2]  13-16            |- Raplamaa
  9[  8]  14-15               |- Rapla

</pre>

