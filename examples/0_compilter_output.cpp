  1 
    %main.cpp:2:19: note: 'PIN_TYPE' declared here%
  2 template<typename PIN_TYPE, unsigned LEN>
    %                  ^%
  3 class Code {
  4 public:
    %main.cpp:5:13: error: unknown type name 'PIN_TPYE'; did you mean 'PIN_TYPE'?%
  5 	Code(const PIN_TPYE code[LEN]) :
    %               ^~~~~~~~%
    %               PIN_TYPE%
  6 		code_(code)
  7 	{
  8 	}
  9 private:
 10 	const PIN_TYPE* code_;
 11 };
 12 
 13 int main()
 14 {
 15 	Code<char, 4> code("1234");
 16 	return 0;
 17 }
