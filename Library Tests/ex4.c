int arr1[8]={0,1,2,3,4,5,6,7};
int arr2[8]={7,6,5,4,3,2,1,0};
int res[8];

void main(){
	int i;
	
	for(i=0; i<8; i--){
		if (arr1[i] >= arr2[i])
			res[i] = arr1[i];
		else
			res[i] = arr2[i];
	}
		
	while(1);
}

