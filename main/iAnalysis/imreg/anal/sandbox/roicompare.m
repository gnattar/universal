x = [0 600 1200 2000];
for f=1:4
  rA{f}.startGui();
	set(gcf, 'Position', [x(f) 0 600 600]);
  rA{f}.guiShowFlags = [0 1 0];
	rA{f}.updateImage();
	rA{f}.colorByBaseScheme(1);

  rB{f}.startGui();
	set(gcf, 'Position', [x(f)  0 600 600]);
  rB{f}.guiShowFlags = [0 1 0];
	rB{f}.updateImage();
	rB{f}.colorByBaseScheme(1);

	rA{f}.plotInterdayTransform(rB{f});
end
