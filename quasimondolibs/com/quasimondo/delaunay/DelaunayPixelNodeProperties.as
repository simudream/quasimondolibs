package com.quasimondo.delaunay
{
	import com.quasimondo.bitmapdata.Pixel;

	public class DelaunayPixelNodeProperties extends DelaunayNodeProperties
	{
		public var pixel:Pixel;
		public function DelaunayPixelNodeProperties( pixel:Pixel )
		{
			this.pixel = pixel;
		}
	}
}