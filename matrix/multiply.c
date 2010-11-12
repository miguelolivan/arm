void multiply (int *a, int *b, int *c)
{
	int i;
	int j;
#define dim  3
	for(i=0;i<dim*dim;i++)
		for(j=0;j<dim;j++)/*i -> i%dim*/
						/*j -> i/dim*/
			c[i]+=a[i%dim+dim*(j)]*b[j+dim*((i/dim))];
}