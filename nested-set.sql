

CREATE TABLE tree (
  id INTEGER PRIMARY KEY,
  parent INTEGER,
  lft INTEGER,
  rgt INTEGER,
  name TEXT
);


INSERT INTO tree (id, parent, lft, rgt, name) VALUES (1, 0, 1, 12, 'root');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (2, 1, 2, 11, 'Eesti');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (3, 2, 3, 10, 'Harjumaa');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (4, 3, 4, 9,  'Tallinn');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (5, 4, 5, 8,  'Kristiine');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (6, 5, 6, 7,  'Tedre');

