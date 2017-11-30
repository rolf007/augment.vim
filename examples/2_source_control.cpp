    %======== 738b9617 Jacob 2015-06-22 15:18:04 ========%
  1 #include <iostream>
  2 #include <vector>
  3 
  4 int main ()
  5 {
    %======== c8484c9b Mike 2015-07-15 12:46:35 ========%
  6   std::vector<int> first;
  7   std::vector<int> second (4,100);
  8   std::vector<int> third (second.begin(),second.end());
  9   std::vector<int> fourth (third);
    %======== 738b9617 Jacob 2015-06-22 15:18:04 ========%
 10 
 11   int myints[] = {16,2,77,29};
 12   std::vector<int> fifth (myints, myints + sizeof(myints) / sizeof(int) );
 13 
    %======== 00000000 Not Committed Yet 2015-07-27 14:37:51 ======== %
 14   std::cout << "The contents of fifth are:";
    %======== 738b9617 Jacob 2015-06-22 15:18:04 ========%
 15   for (std::vector<int>::iterator it = fifth.begin(); it != fifth.end(); ++it)
 16     std::cout << ' ' << *it;
 17   std::cout << '\n';
 18 
 19   return 0;
 20 }
