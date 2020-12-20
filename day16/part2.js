
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
let nearby_tickets = [];
while (line_number < lines.length) {
  if (lines[line_number] != "") {
    nearby_tickets.push(lines[line_number].split(",").map((x) => parseInt(x)));
  }
  line_number += 1;
}

// This constraint captures ALL known constraints together
const total_constraint = new DisjunctionConstraint(fields.map((x) => x.constraint));

// Remove invalid tickets
nearby_tickets = nearby_tickets.filter(function(ticket) {
  for (let field of ticket) {
    if (!total_constraint.satisfied(field))
      return false;
  }
  return true;
});

const possible_assignments = Array(fields.length);
for (let index = 0; index < possible_assignments.length; index++) {
  const possibilities = [];
  fields.forEach(function(field, field_index) {
    let okay = true;
    for (let ticket of nearby_tickets) {
      if (!field.constraint.satisfied(ticket[index])) {
        okay = false;
        break;
      }
    }
    if (okay) {
      possibilities.push(field_index);
    }
  });
  possible_assignments[index] = possibilities;
}

// Assuming that there is a unique solution (which there is, given
// that this is being posed as a puzzle which has an answer), it can
// be shown using a bit of graph theory that the below algorithm will
// terminate. This would fail in general if there were multiple
// solutions, as it would need to be capable of backtracking.

const correct_assignment = Array(fields.length);
for (let _index = 0; _index < fields.length; _index++) {
  // Find a slot which has only one possible field, and assign it.
  for (let slot_index = 0; slot_index < fields.length; slot_index++) {
    if (possible_assignments[slot_index].length == 1) {
      var field_index = possible_assignments[slot_index][0];
      correct_assignment[slot_index] = field_index;
      for (let arr of possible_assignments) {
        var position = arr.indexOf(field_index);
        if (position >= 0)
          arr.splice(position, 1);
      }
    }
  }
}

// Now we have an assignment of slots to fields. Sum up all of the
// fields which start with "departure".
let product = 1;
for (let slot_index = 0; slot_index < fields.length; slot_index++) {
  var field = fields[correct_assignment[slot_index]];
  if (/^departure/.test(field.name)) {
    product *= your_ticket[slot_index];
  }
}
console.log(product);
