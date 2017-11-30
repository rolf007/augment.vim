  1 #include <iostream>
  2 #include <vector>
  3 
  4 int main ()
  5 {
  6   std::vector<int> first;
  7   std::vector<int> second (4,100);
  8   std::vector<int> third (second.begin(),second.end());
  9   std::vector<int> fourth (third);
 10 
 11   int myints[] = {16,2,77,29};
 12   std::vector<int> fifth (myints, myints + sizeof(myints) / sizeof(int) );
 13 
 14   std::cout << "The contents of fifth are:"; %<-- line added%
 15   for (std::vector<int>::iterator it = fifth.begin(); it != fifth.end(); ++it)
 16     std::cout << ' ' << *it;
 17   std::cout << '\n';
 18 
 19   return 0;% <-- changed from "return 1;"%
 20 }
