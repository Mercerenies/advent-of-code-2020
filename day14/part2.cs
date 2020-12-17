
using System;
using System.Linq;
using System.IO;
using System.Collections.Generic;

class Part2 {

  static void Main(string[] args) {
    var memory = new Dictionary<long, long>();
    var mask = new Bitmask();
    foreach (string line in File.ReadLines("input.txt")) {
      var data = line.Split(" = ");
      if (data[0] == "mask") {
        mask = Bitmask.FromString(data[1]);
      } else {
        var value = int.Parse(data[1]);
        var place = int.Parse(new String(data[0].Where(Char.IsDigit).ToArray()));
        foreach (var modifiedPlace in mask.Apply(place)) {
          memory[modifiedPlace] = value;
        }
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
  Ignore, On, Mix,
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
        return MaskState.Ignore;
      case '1':
        return MaskState.On;
      case 'X':
        return MaskState.Mix;
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

  public IEnumerable<long> Apply(long value) {
    return ApplyBits(value, 0);
  }

  private IEnumerable<long> ApplyBits(long value, int bit) {
    if (bit >= BIT_COUNT) {
      yield return value;
      yield break;
    }
    switch (Bits[bit]) {
      case MaskState.Ignore:
        foreach (var v in ApplyBits(value, bit + 1)) {
          yield return v;
        }
        break;
      case MaskState.On:
        value |= (1L << bit);
        foreach (var v in ApplyBits(value, bit + 1)) {
          yield return v;
        }
        break;
      case MaskState.Mix:
        foreach (var v in ApplyBits(value & ~(1L << bit), bit + 1)) {
          yield return v;
        }
        foreach (var v in ApplyBits(value | (1L << bit), bit + 1)) {
          yield return v;
        }
        break;
    }
  }

}
