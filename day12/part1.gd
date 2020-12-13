extends SceneTree

# Run as: godot -s part1.gd

class Ship:
    var position: Vector2
    var direction: Vector2

    func _init():
        position = Vector2()
        direction = Vector2(1, 0)

    func rotate_left():
        direction = Vector2(direction.y, - direction.x)

    func rotate_right():
        direction = Vector2(- direction.y, direction.x)

    func distance_from_start():
        return abs(position.x) + abs(position.y)

class Instruction:
    var dir: String
    var amount: int

    func _init(dir, amount):
        self.dir = dir
        self.amount = amount

    func execute(ship):
        match dir:
            "N":
                ship.position.y -= amount
            "S":
                ship.position.y += amount
            "W":
                ship.position.x -= amount
            "E":
                ship.position.x += amount
            "L":
                for _i in int(amount / 90):
                    ship.rotate_left()
            "R":
                for _i in int(amount / 90):
                    ship.rotate_right()
            "F":
                ship.position += amount * ship.direction

func read_file():
    var result = []

    var file = File.new()
    file.open("input.txt", File.READ)
    while not file.eof_reached():
        var line = file.get_line()
        var dir = line.substr(0, 1)
        var amount = int(line.substr(1))
        result.push_back(Instruction.new(dir, amount))
    file.close()

    return result

func _init():
    var values = read_file()

    var ship = Ship.new()
    for v in values:
        v.execute(ship)
    print(ship.distance_from_start())
    quit()
