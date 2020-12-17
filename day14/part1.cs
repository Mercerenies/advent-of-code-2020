
using System;
using System.Linq;
using System.IO;
using System.Collections.Generic;

class Part1 {

  static void Main(string[] args) {
    var memory = new Dictionary<long, long>();
    var mask = new Bitmask();
    foreach (string line in File.ReadLines("input.txt")) {
      var data = line.Split(" = ");
      if (data[0] == "mask") {
        mask = Bitmask.FromString(data[1]);
      } else {
        var place = int.Parse(new String(data[0].Where(Char.IsDigit).ToArray()));
        var value = mask.Apply(int.Parse(data[1]));
        memory[place] = value;
      }
    }
    long sum = 0L;
    foreach (var entry in memory) {
      sum += entry.Value;
    }
    Console.WriteLine(sum);
  }

}

enum MaskState {
  Off, On, Ignore,
}

class Bitmask {
  public const int BIT_COUNT = 36;

  // Least significant bit first
  private MaskState[] Bits;

  public Bitmask() {
    Bits = new MaskState[BIT_COUNT];
  }

  public static MaskState CharToState(char ch) {
    switch (ch) {
      case '0':
        return MaskState.Off;
      case '1':
        return MaskState.On;
      case 'X':
        return MaskState.Ignore;
      default:
        throw new Exception("Cannot convert " + ch + " to MaskState");
    }
  }

  public static Bitmask FromString(string line) {
    var mask = new Bitmask();
    for (var i = 0; i < BIT_COUNT; i++) {
      mask.Bits[i] = CharToState(line[line.Length - i - 1]);
    }
    return mask;
  }

  public long Apply(long value) {
    for (var i = 0; i < BIT_COUNT; i++) {
      var pos = 1L << i;
      switch (Bits[i]) {
        case MaskState.Off:
          value &= ~pos;
          break;
        case MaskState.On:
          value |= pos;
          break;
        case MaskState.Ignore:
          break;
      }
    }
    return value;
  }

}
