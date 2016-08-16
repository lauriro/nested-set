Nested set model example
========================


<pre>
$ ./nested-set.sh

Nested set model example
========================

Commands are:
  init                          Create database
  print                         Print tree
  add [parent_id] [name]        Add node to end
  addFirst [parent_id] [name]   Add node to beginning
  del [node_id]                 Remove node with childs
  delOne [node_id]              Remove only node and move childs under parent
  move [node_id] [parent_id]    Move node under new parent
  swap [node_id] [node_id]      Swap two node with childs
  order [node_id] [child_ids]   Sort childs
  path [node_id]                Print path
  childs [node_id]              Print childs
  leafs                         Print leafs
  rebuild                       Rebuild left and right indexes
  reset                         Delete database and init again


$ ./nested-set.sh init
  1[  0]   1-16    └─┬ World
  2[  1]   2-3       ├── Europe
  3[  1]   4-15      └─┬ Asia
  4[  3]   5-10        ├─┬ China
  5[  4]   6-7         │ ├── Shanghai
  6[  4]   8-9         │ └── Beijing
  7[  3]  11-14        └─┬ India
  8[  7]  12-13          └── Mumbai

$ ./nested-set.sh add 2 Germany
  1[  0]   1-18    └─┬ World
  2[  1]   2-5       ├─┬ Europe
  9[  2]   3-4       │ └── Germany
  3[  1]   6-17      └─┬ Asia
  4[  3]   7-12        ├─┬ China
  5[  4]   8-9         │ ├── Shanghai
  6[  4]  10-11        │ └── Beijing
  7[  3]  13-16        └─┬ India
  8[  7]  14-15          └── Mumbai

$ ./nested-set.sh swap 3 2
  1[  0]   1-18    └─┬ World
  3[  1]   2-13      ├─┬ Asia
  4[  3]   3-8       │ ├─┬ China
  5[  4]   4-5       │ │ ├── Shanghai
  6[  4]   6-7       │ │ └── Beijing
  7[  3]   9-12      │ └─┬ India
  8[  7]  10-11      │   └── Mumbai
  2[  1]  14-17      └─┬ Europe
  9[  2]  15-16        └── Germany

$ ./nested-set.sh path 8
  1[  0]   1-18    └─┬ World
  3[  1]   2-13      ├─┬ Asia
  7[  3]   9-12      │ └─┬ India
  8[  7]  10-11      │   └── Mumbai

$ ./nested-set.sh childs 3
  3[  1]   2-13    └─┬ Asia
  4[  3]   3-8       ├─┬ China
  5[  4]   4-5       │ ├── Shanghai
  6[  4]   6-7       │ └── Beijing
  7[  3]   9-12      └─┬ India
  8[  7]  10-11        └── Mumbai

</pre>

