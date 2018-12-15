// Does the important part faster than Bash can

#include <deque>
#include <algorithm>
#include <iostream>
#include <stdlib.h>
#include <stdint.h>

using namespace std;

int main(int argc, char **argv)
{
  if (argc < 3)
  {
    cerr << "Not enough arguments!\n";
    cerr << "Usage: " << argv[0] << " <players> <marble count>";
    return 1;
  }

  if (sizeof(int) < 4)
  {
    cerr << "Integer size too small! Numbers will probably overflow!\n";
  }
  int elves = atoi(argv[1]);
  int count = atoi(argv[2]);

  uint32_t *scores = new uint32_t[elves];
  deque<uint32_t> marbles;
  marbles.push_back(0);

  int current = 0;
  int elf = 0;

  cout << "Players: " << elves << "; highest marble: " << count << endl;
  for (uint32_t i = 0; i < count; i++)
  {
    elf = (elf + 1) % elves;
    uint32_t marble = i+1;
    if ( marble % 23 == 0 )
    {
      current -= 7;
      if (current < 0) current += marbles.size();
      scores[elf] += marbles[current] + marble;
      marbles.erase(marbles.begin() + current);
    }
    else
    {
      current = (current + 1) % marbles.size() + 1;
      marbles.insert(marbles.begin() + current, marble);
    }
    if (i % 100 == 0) cout << (i * 100 / count) << "% complete\r";
  }

  cout << "Scores:\n";
  sort(scores, scores + elves);
  for (uint32_t i = 0; i < elves; i++)
  {
    cout << scores[i] << endl;
  }
  delete[] scores;
}
