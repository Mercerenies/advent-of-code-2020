
const fs = require('fs');

class Field {
  constructor(name, constraint) {
    this.name = name;
    this.constraint = constraint;
  }
}

class RangeConstraint {
  constructor(min, max) {
    this.min = min;
    this.max = max;
  }
  satisfied(n) {
    return (n >= this.min) && (n <= this.max);
  }
}

class DisjunctionConstraint {
  constructor(constraints) {
    this.constraints = constraints;
  }
  satisfied(n) {
    for (let constraint of this.constraints) {
      if (constraint.satisfied(n))
        return true;
    }
    return false;
  }
}

function parseField(line) {
  const match = /([\w ]+): (\d+)-(\d+) or (\d+)-(\d+)/.exec(line);
  const [_, name, min1, max1, min2, max2] = match;
  const constraint = new DisjunctionConstraint([
    new RangeConstraint(parseInt(min1), parseInt(max1)),
    new RangeConstraint(parseInt(min2), parseInt(max2)),
  ]);
  return new Field(name, constraint);
}

const lines = fs.readFileSync('input.txt', 'utf8').split("\n");
let line_number = 0;

// Parse fields
const fields = [];
while (lines[line_number] != "") {
  fields.push(parseField(lines[line_number]));
  line_number += 1;
}

// Your ticket
line_number += 2;
const your_ticket = lines[line_number].split(",").map((x) => parseInt(x));

// Nearby tickets
line_number += 3;
const nearby_tickets = [];
while (line_number < lines.length) {
  if (lines[line_number] != "") {
    nearby_tickets.push(lines[line_number].split(",").map((x) => parseInt(x)));
  }
  line_number += 1;
}

// This constraint captures ALL known constraints together
const total_constraint = new DisjunctionConstraint(fields.map((x) => x.constraint));

let sum = 0;
for (let ticket of nearby_tickets) {
  for (let field of ticket) {
    if (!total_constraint.satisfied(field)) {
      sum += field;
    }
  }
}
console.log(sum);
