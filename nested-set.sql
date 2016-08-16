

CREATE TABLE tree (
  id INTEGER PRIMARY KEY,
  parent INTEGER,
  lft INTEGER,
  rgt INTEGER,
  name TEXT
);


INSERT INTO tree (id, parent, lft, rgt, name) VALUES (1, 0, 1, 16, 'World');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (2, 1, 2, 3,  'Europe');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (3, 1, 4, 15, 'Asia');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (4, 3, 5, 10, 'China');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (5, 4, 6, 7,  'Shanghai');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (6, 4, 8, 9,  'Beijing');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (7, 3, 11, 14,  'India');
INSERT INTO tree (id, parent, lft, rgt, name) VALUES (8, 7, 12, 13,  'Mumbai');

