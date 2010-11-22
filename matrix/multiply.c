void c_multiply (int *a, int *b, int *c)
{
	int i;
	int j;
#define dim  3
	for(i=0;i<dim;i++)
		for(j=0;j<dim;j++)
			{	
					c[j+dim*i]=a[0+dim*i]*b[j+dim*0]+a[1+dim*i]*b[j+dim*1]+a[2+dim*i]*b[j+dim*2];
			}
}
