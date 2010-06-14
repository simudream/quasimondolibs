/*

	Linear Mesh Class v1.0

	released under MIT License (X11)
	http://www.opensource.org/licenses/mit-license.php

	Author: Mario Klingemann
	http://www.quasimondo.com
	
	Copyright (c) 2006-2010 Mario Klingemann
*/


package com.quasimondo.geom
{
	import com.quasimondo.geom.pointStructures.BalancingKDTree;
	import com.quasimondo.geom.pointStructures.KDTreeNode;
	import com.signalsondisplay.structs.graphs.Graph;
	import com.signalsondisplay.structs.graphs.Vertex;
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	
	public class LinearMesh
	{
		public var treeCleanupCycle:uint = 500;
		private var treeOperationCount:uint;
		private var tree:BalancingKDTree;
		
		private var points:Vector.<Vector2>;
		private var vertices:Array;
		private var edges:Object;
		private var edgeCount:int;
		private var pointCount:int;
		
		private var pointsToIndex:Dictionary;
		private var freeIndices:Vector.<int>;
		private var graph:Graph;	
		
		public var squaredSnapDistance:Number = Math.pow( 0.000001, 2 );
		
		
		
		public function LinearMesh()
		{
			reset();
		}
		
		
		public function addVector2( point:Vector2 ):int
		{
			var index:int = getPointIndex( point );
			if ( index != -1 ) return index;
			
			if ( freeIndices.length > 0 )
			{
				index = freeIndices.pop();
			} else {
				index = points.length;
			}
			addPoint( index, point );
			return index;
		}
		
		public function addLineSegment( line:LineSegment ):void
		{
			if ( line.length == 0 ) return;
			
			var p:Vector2;
			
			var p1_index:int = getPointIndex(line.p1 );
			if ( p1_index != -1 ) line.p1 = points[p1_index];
			var p2_index:int = getPointIndex(line.p2 );
			if ( p2_index != -1 ) line.p2 = points[p2_index];
			
			if ( p1_index == -1 )
			{
				if ( freeIndices.length > 0 )
				{
					p1_index = freeIndices.pop();
				} else {
					p1_index = points.length;
				}
				addPoint( p1_index, line.p1 );
			}
			
			if ( p2_index == -1 )
			{
				if ( freeIndices.length > 0 )
				{
					p2_index = freeIndices.pop();
				} else {
					p2_index = points.length;
				}
				
				addPoint( p2_index, line.p2 );
			}
			
			var l:LineSegment;
			var newIndex:int;
			var indices:Array;
			var intersections:Vector.<Vector2>;
			var idx1:int, idx2:int;
			var id1:String = "|"+p1_index+"|";
			var id2:String = "|"+p2_index+"|";
			var d1:Number, d2:Number;
			var intersectionInfos:Vector.<IntersectionInfo> = new Vector.<IntersectionInfo>();
				
			intersectionInfos.push( new IntersectionInfo(line.p1, "", null ));	
			intersectionInfos.push( new IntersectionInfo(line.p2, "", null ));	
				
			for ( var id:String in edges )
			{
				if ( id.indexOf(id1) == -1 &&  id.indexOf(id2) == -1 )
				{
					l = LineSegment(edges[id]);
					intersections = line.getIntersection( l, true );
					if ( intersections.length == 1 )
					{
						intersectionInfos.push( new IntersectionInfo(intersections[0], id, l ));
					} else if ( intersections.length > 1 )
					{
						intersectionInfos.push( new IntersectionInfo(intersections[0], id, l ));
						intersectionInfos.push( new IntersectionInfo(intersections[1], id, l ));
					}
				} 
			}
			
			intersectionInfos.sort( function ( a:IntersectionInfo, b:IntersectionInfo ):int
			{
				if ( a.intersection.x < b.intersection.x ) return -1;
				if ( a.intersection.x > b.intersection.x ) return 1;
				if ( a.intersection.y < b.intersection.y ) return -1;
				if ( a.intersection.y > b.intersection.y ) return 1;
				return 0;
			} )	;
			
			for ( var i:int = intersectionInfos.length; --i > -1; )
			{
				var info:IntersectionInfo = intersectionInfos[i];
				if ( info.line != null && line.p1.equals( info.intersection ) )
				{
					intersectionInfos.splice(i,1);
					removeConnection( info.connectionID );
					
					indices = info.connectionID.split("|");
					idx1 = parseInt(indices[1]);
					idx2 = parseInt(indices[2]);
					
					addEdge( idx1, p1_index );
					addEdge( idx2, p1_index );
				} else if ( info.line != null && line.p2.equals( info.intersection ) )
				{
					intersectionInfos.splice(i,1);
					removeConnection( info.connectionID );
					
					indices = info.connectionID.split("|");
					idx1 = parseInt(indices[1]);
					idx2 = parseInt(indices[2]);
					
					addEdge( idx1, p2_index );
					addEdge( idx2, p2_index );
				}
			}
			
			
			var lastP:Vector2;
			var lastIndex:int;
			
			for ( i = 0; i < intersectionInfos.length; i++ )
			{
				info = intersectionInfos[i];
				p = info.intersection;
				if ( info.line != null && info.line.p1.squaredDistanceToVector( p ) <= squaredSnapDistance  )
				{	
					p = info.line.p1;
					newIndex = pointsToIndex[p];
				} else if ( info.line != null && info.line.p2.squaredDistanceToVector( p ) <= squaredSnapDistance  )
				{
					p = info.line.p2;
					newIndex = pointsToIndex[p];
				} else if ( line.p1.squaredDistanceToVector( p ) <= squaredSnapDistance  )
				{	
					p = line.p1;
					newIndex = pointsToIndex[p];
				} else if ( line.p2.squaredDistanceToVector( p ) <= squaredSnapDistance  )
				{
					p = line.p2;
					newIndex = pointsToIndex[p];
				} else {
					if ( freeIndices.length > 0 )
					{
						newIndex = freeIndices.pop();
					} else {
						newIndex = points.length;
					}
					
					addPoint( newIndex, p );
					
					removeConnection( info.connectionID );
					
					indices = info.connectionID.split("|");
					idx1 = parseInt(indices[1]);
					idx2 = parseInt(indices[2]);
					
					addEdge( idx1, newIndex );
					addEdge( idx2, newIndex );
				}
				
				if ( lastP != null && lastIndex != newIndex )
				{
					addEdge( lastIndex, newIndex );
				}
				lastP = p;
				lastIndex = newIndex;
			}
			
		}
		
		public function getPointIndex( p:Vector2 ):int
		{
			var nearest:Vector2 = getNearestPoint( p );
			if ( nearest == null ) return -1;
			return nearest.squaredDistanceToVector( p ) <= squaredSnapDistance  ? pointsToIndex[nearest] : -1;
		}
		
		public function removePoint( p:Vector2 ):void
		{
			var index:int = getPointIndex( p );
			if( index != -1 ) removePointAt( index );
		}
		
		public function removePolygon( poly:Polygon ):void
		{
			var points:Vector.<Vector2> = poly.getCopyOfPoints();
			for ( var i:int = 0; i < points.length; i++ )
			{
				removePoint( points[i] );
			}
		}
		
		public function getNearestPoint( p:Vector2 ):Vector2
		{
			var nearestNode:KDTreeNode = tree.findNearestFor( p );
			return ( nearestNode != null ? nearestNode.point : null );
		}
		
		
		private function addPoint( index:int, point:Vector2 ):void
		{
			pointCount++;
			points[index] = point;
			pointsToIndex[ point ] = index;
			graph.addVertex(vertices[index] = new Vertex("", index));
			tree.insertPoint( point );
			treeOperationCount++;
			if ( treeOperationCount == treeCleanupCycle )
			{
				tree.rebalance();
				treeOperationCount = 0;
			}
		}
		
		private function removePointAt( index:int ):void
		{
			tree.removeNearest( points[index] );
			treeOperationCount++;
			if ( treeOperationCount == treeCleanupCycle )
			{
				tree.rebalance();
				treeOperationCount = 0;
			}
			
			pointCount--;
			delete pointsToIndex[ points[index] ];
			points[index] = null;
			graph.removeVertex( vertices[index] );
			vertices[index] = null;
			
			var pointID:String = "|"+index+"|";
			for ( var id:String in edges )
			{
				if ( id.indexOf(pointID) > -1 ) {
					edges[id] = null;
					delete edges[id];
				}
			}
		}
		
		private function addEdge( index1:int, index2:int ):String
		{
			if ( points[index1] == points[index2]) 
			{
				trace("Error: same index for edge");
			}
			var id:String;
			var l:LineSegment = new LineSegment( points[index1], points[index2] );
			if ( l.length == 0) 
			{
				trace("Error: line length 0");
			}
			
			edges[ id = "|"+( index1 < index2 ? index1 +"|" + index2 : index2 +"|" + index1 ) + "|"] = l;
			
			if ( vertices[index1] == null ) vertices[index1] = new Vertex(index1.toString());
			if ( vertices[index2] == null ) vertices[index2] = new Vertex(index2.toString());
			graph.addEdge(vertices[index1], vertices[index2], l.length );
			edgeCount++;
			return id;
		}
		
		public function removeConnection( id:String ):void
		{
			edges[id] = null;
			delete edges[id];
			var indices:Array = id.split("|");
			edgeCount--;
			graph.removeEdge(vertices[parseInt(indices[1])], vertices[parseInt(indices[2])] );
		}
		
		public function addRectangle( rect:Rectangle ):void
		{
			var p1:Vector2 = new Vector2( rect.topLeft );
			var p2:Vector2 = new Vector2( rect.right, rect.top );
			var p3:Vector2 = new Vector2( rect.bottomRight );
			var p4:Vector2 = new Vector2( rect.left, rect.bottom );
			
			addLineSegment( new LineSegment( p1, p2) );
			addLineSegment( new LineSegment( p2, p3) );
			addLineSegment( new LineSegment( p3, p4) );
			addLineSegment( new LineSegment( p4, p1) );
		}
		
		public function addPolygon( poly:Polygon ):void
		{
			for ( var i:int = 0; i < poly.pointCount; i++ )
			{
				addLineSegment( poly.getSide( i ) );
			}
		}
		
		public function addConvexPolygon( poly:ConvexPolygon ):void
		{
			for ( var i:int = 0; i < poly.pointCount; i++ )
			{
				addLineSegment( poly.getSide( i ) );
			}
		}
		
		public function addTriangle( poly:Triangle ):void
		{
			for ( var i:int = 0; i < 3; i++ )
			{
				addLineSegment( poly.getSide( i ) );
			}
		}
		
		public function addCircle( circle:Circle, maxSegmentLength:Number = 2 ):void
		{
			addPolygon( circle.toPolygon( maxSegmentLength ) )
		}
		
		public function reset():void
		{
			points = new Vector.<Vector2>;
			vertices = [];
			
			freeIndices = new Vector.<int>();
			graph = new Graph();
			pointsToIndex = new Dictionary( true );
			edges = {};
			edgeCount = 0;
			pointCount = 0;
			treeOperationCount = 0;
			
			tree = new BalancingKDTree();
		}
		
		public function removeOrphans( maxLevel:int = -1 ):void
		{
			var connectionsPerPoint:Vector.<int> = getConnectionsPerPoint();
			var removed:Boolean = false;
			for ( var i:int = 0; i < connectionsPerPoint.length; i++ )
			{
				if ( points[i]!= null && connectionsPerPoint[i] < 2 )
				{
					freeIndices.push(i);
					var pointID:String = "|"+i+"|";
					for ( var id:String in edges )
					{
						if ( id.indexOf(pointID) > -1 )
						{
							removeConnection( id );
							break;
						}
					}
					removePointAt( i );
					removed = true;
				}
			}
			if ( removed && maxLevel-1 != 0) removeOrphans( maxLevel-1 );
		}
		
		// filterFunction( egde:LineSegment, connectionsAtPoint1:int, connectionsAtPoint2:int ):Boolean;
		
		public function filterEdges( filterFunction:Function, priorityFunction:Function = null ):void
		{
			var id:String;
			var connectionsPerPoint:Vector.<int> = getConnectionsPerPoint();
			var indices:Array;
			if ( priorityFunction == null )
			{
				for ( id in edges )
				{
					indices = id.split("|");
					if ( !filterFunction( edges[id], connectionsPerPoint[parseInt(indices[1])], connectionsPerPoint[parseInt(indices[2])] ))
					{
						removeConnection( id );
						connectionsPerPoint[parseInt(indices[1])]--;
						connectionsPerPoint[parseInt(indices[2])]--;
					}
				}
			} else {
				var candidates:Vector.<LineSegment> = new Vector.<LineSegment>();
				for ( id in edges )
				{
					indices = id.split("|");
					if ( !filterFunction( edges[id], connectionsPerPoint[parseInt(indices[1])], connectionsPerPoint[parseInt(indices[2])] ))
					{
						candidates.push(edges[id]);
					}
				}
				
				candidates.sort(priorityFunction);
				
				for ( i = 0; i < candidates.length; i++ )
				{
					var idx1:int = pointsToIndex[candidates[i].p1];
					var idx2:int = pointsToIndex[candidates[i].p2];
					if ( !filterFunction( candidates[i], connectionsPerPoint[idx1], connectionsPerPoint[idx2] ))
					{
						id = "|" + ( idx1 < idx2 ? idx1 + "|" + idx2 : idx2 + "|" + idx1 ) + "|" ;
						removeConnection( id );
						connectionsPerPoint[idx1]--;
						connectionsPerPoint[idx2]--;
					}
				}	
				
			}
			//connectionsPerPoint = getConnectionsPerPoint();
			for ( var i:int = 0; i < connectionsPerPoint.length; i++ )
			{
				if ( points[i] != null && connectionsPerPoint[i] == 0 )
				{
					freeIndices.push(i);
					removePointAt(i);
				}
			}
		}
		
		// filterFunction( edgeInfo:MeshEdgeInfo ):Boolean;
		public function findEdges( filterFunction:Function ):Vector.<MeshEdgeInfo>
		{
			var result:Vector.<MeshEdgeInfo> = new Vector.<MeshEdgeInfo>();
			var connectionsPerPoint:Vector.<int> = getConnectionsPerPoint();
			
			for ( var id:String in edges )
			{
				var edgeInfo:MeshEdgeInfo;
				var indices:Array = id.split("|");
				var i1:int = parseInt(indices[1]);
				var i2:int = parseInt(indices[2]);
				if ( LineSegment(edges[id]).p1 == points[i1] )
				{
					edgeInfo = new MeshEdgeInfo( id, i1, i2, edges[id] as LineSegment, connectionsPerPoint[i1], connectionsPerPoint[i2] );
				} else {
					edgeInfo = new MeshEdgeInfo( id, i2, i1, edges[id] as LineSegment, connectionsPerPoint[i2], connectionsPerPoint[i1] );
				}
				
				if ( filterFunction( edgeInfo ))
				{
					result.push( edgeInfo );
				}
			}
			
			return result;
		}
		
		
		public function getConnectionsPerPoint():Vector.<int>
		{
			var connectionCount:Vector.<int> = new Vector.<int>( points.length, true );
			for ( var id:String in edges )
			{
				var indices:Array = id.split("|");
				connectionCount[parseInt(indices[1])]++;
				connectionCount[parseInt(indices[2])]++;
			}
			return connectionCount;
		}
		
		public function getConnectionsForPoint( index:int ):Vector.<String>
		{
			var pointID:String = "|"+index+"|";
			var connectionIDs:Vector.<String> = new Vector.<String>();
			for ( var id:String in edges )
			{
				if ( id.indexOf(pointID) > -1 ) {
					connectionIDs.push(id);
				}
			}
			return connectionIDs;
		}
		
		public function getConnectedIndices( index:int ):Vector.<int>
		{
			var pointID:String = "|"+index+"|";
			var connectionIndices:Vector.<int> = new Vector.<int>();
			for ( var id:String in edges )
			{
				if ( id.indexOf(pointID) > -1 ) {
					var ids:Array = id.split("|");
					connectionIndices.push( int( ids[1] == String(index) ? ids[2] : ids[1]) );
				}
			}
			return connectionIndices;
		}
		
		/*
		public function getPolygons():Vector.<Polygon>
		{
			var index:int;
			var indices:Array;
			var vertex1:Vertex, vertex2:Vertex, result:Vertex;
			var d:Dijkstra;
			var polys:Vector.<Polygon> = new Vector.<Polygon>();
			var polyIndices:Vector.<int>;
			var minIndex:int;
			var minID:int;
			var check:String;
			var polyCheck:Dictionary = new Dictionary();
			var polygon:Polygon;
			var usedEdges:Dictionary = new Dictionary();
			
			for ( var id:String in edges ) {
				trace( "EDGE "+id );
				
				if ( usedEdges[id] >= 2 ) {
					trace("edge "+id+" used "+usedEdges[id]+" times: skipping");
					continue;
				}
				indices = id.split("|");
				vertex1 = vertices[ indices[1]];
				vertex2 = vertices[ indices[2]];
				graph.removeEdge( vertex1,vertex2 );
				
				polyIndices = new Vector.<int>();
				minID = vertex2.index;
				minIndex = 0;
				result = new Dijkstra( graph, vertex1, vertex2 ).search();
				while ( result != null )
				{
					polyIndices.push( result.index );
					if ( result.index < minID )
					{
						minID = result.index;
						minIndex = polyIndices.length - 1;
					}
					result = result.parent;
				}
				
				trace("order: "+polyIndices.toString());
				
				graph.addEdge( vertex1,vertex2 );
				
				if ( polyIndices.length > 2 )
				{
					if ( minIndex > 0 )
					{
						polyIndices = polyIndices.concat( polyIndices.splice( 0, minIndex ) );
					}
					
					check = polyIndices.toString();
					if ( !polyCheck[check] )
					{
						polyCheck[check] = true;
						polyIndices.reverse();
						polyIndices.splice(0,0,polyIndices.pop());
						polyCheck[polyIndices.toString()] = true;
						
						polygon = new Polygon();
						for each ( index in polyIndices )
						{
							polygon.addPoint( points[index] );
						}
						polys.push( polygon );
						
						for ( var i:int = 0; i < polyIndices.length; i++ )
						{
							var index1:int = polyIndices[i];
							var index2:int = polyIndices[int((i+1) % polyIndices.length)];
							var id:String = "|"+( index1 < index2 ? index1 +"|" + index2 : index2 +"|" + index1 ) + "|";
							if ( usedEdges[id] == null ) usedEdges[id] = 1 else usedEdges[id]++;
						}
						
					} else {
						trace( "already found" );
					}
				}
			}
			
			
			trace( "points: ", pointCount );
			trace( "edges: ", edgeCount );
			trace( "faces: ", polys.length );
			
			trace( "euler-check: ", pointCount - edgeCount + polys.length );
			//V-E+F=2
			
			
			return polys;
		}
		*/
		
		public function getPolygons():Vector.<Polygon>
		{
			var pointsByAngles:Dictionary = getAngleSortedConnections();
			var walked:Dictionary = new Dictionary()
			var lastIndex:int, startIndex:int, nextIndex:int;
			var polygons:Vector.<Polygon> = new Vector.<Polygon>();
			var polygon:Polygon = new Polygon();
			var pointIndices:Array;
			var minPolyIndex:int, minPointIndex:int;
			var check:String;
			var polyCheck:Dictionary = new Dictionary();
			
			for ( var index:String in pointsByAngles )
			{
				lastIndex = startIndex = parseInt(index);
				var connectedTo:Array = pointsByAngles[index];
				var c:int = 0;
				while ( c < connectedTo.length )
				{
					if ( walked[startIndex+"|"+connectedTo[c]] == null )
					{
						break;
					} 
					c++;
				}
				
				if ( c == connectedTo.length ) continue;
				
				nextIndex = connectedTo[c];
				walked[startIndex+"|"+connectedTo[c]] = true;
				polygon.addPoint( points[startIndex] );
				pointIndices = [startIndex];
				minPolyIndex = 0;
				minPointIndex = startIndex;
				
				
				while( nextIndex != startIndex  )
				{
					connectedTo = pointsByAngles[nextIndex];
					for ( var i:int = 0; i < connectedTo.length; i++ )
					{
						if ( connectedTo[i] == lastIndex )
						{
							lastIndex = nextIndex;
							nextIndex = connectedTo[(i - 1 + connectedTo.length) % connectedTo.length];
							break;
						}
					}
					pointIndices.push(lastIndex);	
					polygon.addPoint( points[lastIndex] );
					if ( lastIndex < minPointIndex )
					{
						minPointIndex = lastIndex;
						minPolyIndex = pointIndices.length -1;
					}
					if ( walked[lastIndex+"|"+nextIndex] ) break;
					walked[lastIndex+"|"+nextIndex] = true;
				}
				
				if ( minPolyIndex > 0 )
				{
					pointIndices = pointIndices.concat( pointIndices.splice( 0, minPolyIndex ) );
				}
				
				check = pointIndices.toString();
			
				if ( !polyCheck[check] && polygon.area > 0 )
				{
					if (  pointIndices.slice().sort(Array.UNIQUESORT) != 0 )
					{
						
						polyCheck[check] = true;
						pointIndices.reverse();
						pointIndices.splice(0,0,pointIndices.pop());
						polyCheck[pointIndices.toString()] = true;	
						polygons.push(polygon);
					}
				}
				
				polygon = new Polygon();
			}
			/*
			trace( "points: ", pointCount );
			trace( "edges: ", edgeCount );
			trace( "faces: ", polygons.length );
			
			trace( "euler-check: ", pointCount - edgeCount + polygons.length );
			*/
			return polygons;
		}
		
		
		
		public function getRejectedPolygons():Vector.<Polygon>
		{
			var pointsByAngles:Dictionary = getAngleSortedConnections();
			var walked:Dictionary = new Dictionary()
			var lastIndex:int, startIndex:int, nextIndex:int;
			var polygons:Vector.<Polygon> = new Vector.<Polygon>();
			var polygon:Polygon = new Polygon();
			var pointIndices:Array;
			var minPolyIndex:int, minPointIndex:int;
			var check:String;
			var polyCheck:Dictionary = new Dictionary();
			
			for ( var index:String in pointsByAngles )
			{
				lastIndex = startIndex = parseInt(index);
				var connectedTo:Array = pointsByAngles[index];
				var c:int = 0;
				while ( c < connectedTo.length )
				{
					if ( walked[startIndex+"|"+connectedTo[c]] == null )
					{
						break;
					} 
					c++;
				}
				
				if ( c == connectedTo.length ) continue;
				
				nextIndex = connectedTo[c];
				walked[startIndex+"|"+connectedTo[c]] = true;
				polygon.addPoint( points[startIndex] );
				pointIndices = [startIndex];
				minPolyIndex = 0;
				minPointIndex = startIndex;
				
				
				while( nextIndex != startIndex  )
				{
					connectedTo = pointsByAngles[nextIndex];
					for ( var i:int = 0; i < connectedTo.length; i++ )
					{
						if ( connectedTo[i] == lastIndex )
						{
							lastIndex = nextIndex;
							nextIndex = connectedTo[(i - 1 + connectedTo.length) % connectedTo.length];
							break;
						}
					}
					pointIndices.push(lastIndex);	
					polygon.addPoint( points[lastIndex] );
					if ( lastIndex < minPointIndex )
					{
						minPointIndex = lastIndex;
						minPolyIndex = pointIndices.length -1;
					}
					if ( walked[lastIndex+"|"+nextIndex] ) break;
					walked[lastIndex+"|"+nextIndex] = true;
				}
				
				if ( minPolyIndex > 0 )
				{
					pointIndices = pointIndices.concat( pointIndices.splice( 0, minPolyIndex ) );
				}
				
				check = pointIndices.toString();
				
				if ( !polyCheck[check] && polygon.area > 0 )
				{
					if (  pointIndices.slice().sort(Array.UNIQUESORT) != 0 )
					{
						
						polyCheck[check] = true;
						pointIndices.reverse();
						pointIndices.splice(0,0,pointIndices.pop());
						polyCheck[pointIndices.toString()] = true;	
						//polygons.push(polygon);
					} else {
						polygons.push(polygon);
					}
				} else {
					polygons.push(polygon);
				}
				
				polygon = new Polygon();
			}
			/*
			trace( "points: ", pointCount );
			trace( "edges: ", edgeCount );
			trace( "faces: ", polygons.length );
			
			trace( "euler-check: ", pointCount - edgeCount + polygons.length );
			*/
			return polygons;
		}
		
		
		public function getInnerEdges():Vector.<MeshEdgeInfo>
		{
			var result:Vector.<MeshEdgeInfo> = new Vector.<MeshEdgeInfo>()
				
			var pointsByAngles:Dictionary = getAngleSortedConnections();
			var walked:Dictionary = new Dictionary()
			var lastIndex:int, startIndex:int, nextIndex:int;
			
			var pointIndices:Array;
			var minPolyIndex:int, minPointIndex:int;
			var check:String;
			var polyCheck:Dictionary = new Dictionary();
			var polyEdges:Dictionary = new Dictionary();
			var polygon:Polygon = new Polygon();
			var indexList:Vector.<Array> = new Vector.<Array>();
			
			for ( var index:String in pointsByAngles )
			{
				lastIndex = startIndex = parseInt(index);
				var connectedTo:Array = pointsByAngles[index];
				var c:int = 0;
				while ( c < connectedTo.length )
				{
					if ( walked[startIndex+"|"+connectedTo[c]] == null )
					{
						break;
					} 
					c++;
				}
				
				if ( c == connectedTo.length ) continue;
				
				nextIndex = connectedTo[c];
				walked[startIndex+"|"+connectedTo[c]] = true;
				polygon.addPoint( points[startIndex] );
				
				pointIndices = [startIndex];
				minPolyIndex = 0;
				minPointIndex = startIndex;
				
				while( nextIndex != startIndex  )
				{
					connectedTo = pointsByAngles[nextIndex];
					for ( var i:int = 0; i < connectedTo.length; i++ )
					{
						if ( connectedTo[i] == lastIndex )
						{
							lastIndex = nextIndex;
							nextIndex = connectedTo[(i - 1 + connectedTo.length) % connectedTo.length];
							break;
						}
					}
					pointIndices.push(lastIndex);	
					polygon.addPoint( points[lastIndex] );
					if ( lastIndex < minPointIndex )
					{
						minPointIndex = lastIndex;
						minPolyIndex = pointIndices.length -1;
					}
					if ( walked[lastIndex+"|"+nextIndex] ) break;
					walked[lastIndex+"|"+nextIndex] = true;
				}
				
				if ( minPolyIndex > 0 )
				{
					pointIndices = pointIndices.concat( pointIndices.splice( 0, minPolyIndex ) );
				}
				
				check = pointIndices.toString();
				
				if ( !polyCheck[check] && polygon.area > 0)
				{
					if (  pointIndices.slice().sort(Array.UNIQUESORT) != 0 )
					{
						polyCheck[check] = true;
						pointIndices.reverse();
						pointIndices.splice(0,0,pointIndices.pop());
						polyCheck[pointIndices.toString()] = true;	
						indexList.push( pointIndices.concat() );
						
					}
				}
				polygon = new Polygon();
			}
			
			var connectionsPerPoint:Vector.<int> = getConnectionsPerPoint();
			
			for ( var j:int = 0; j < indexList.length; j++ )
			{
				pointIndices = indexList[j];
				for ( i = 0; i < pointIndices.length; i++ )
				{
					
					var idx1:int = Math.min( pointIndices[i], pointIndices[(i+1) % pointIndices.length]);
					var idx2:int = Math.max( pointIndices[i], pointIndices[(i+1) % pointIndices.length]);
					var id:String = "|"+ idx1 +"|" + idx2 + "|";
					if ( polyEdges[id] )
					{
						var edgeInfo:MeshEdgeInfo;
						if ( LineSegment(edges[id]).p1 == points[idx1] )
						{
							edgeInfo = new MeshEdgeInfo( id, idx1, idx2, edges[id] as LineSegment, connectionsPerPoint[idx1], connectionsPerPoint[idx2] );
						} else {
							edgeInfo = new MeshEdgeInfo( id, idx2, idx1, edges[id] as LineSegment, connectionsPerPoint[idx2], connectionsPerPoint[idx1] );
						}
						result.push( edgeInfo );
					} else {
						polyEdges[id] = true;
					}
				}
			}
			
			
			return result;
		}
		
		
		
		
		public function getAngleSortedConnections():Dictionary
		{
			var result:Dictionary = new Dictionary();
			for ( var i:int = 0; i < points.length; i++ )
			{
				if ( points[i] == null ) continue;
				var connections:Vector.<String> = getConnectionsForPoint( i );
				var d:Array = [];
				for ( var j:int = 0; j <connections.length; j++)
				{
					var connection:LineSegment = edges[connections[j]];
					d.push( { index:( connection.p1 == points[i] ? pointsToIndex[connection.p2] : pointsToIndex[connection.p1] ), angle:(( connection.p1 == points[i] ? connection.angle : connection.angle + Math.PI ) + 2*Math.PI) % ( 2* Math.PI )} );
				}
				
				d.sortOn("angle",Array.NUMERIC );
				result[i] = [];
				for ( j = 0; j < d.length; j++)
				{
					result[i].push( d[j].index );
				}
			}
			return result;
		}
		
		public function getPoints( connectionsFilter:Function ):Vector.<Vector2>
		{
			var result:Vector.<Vector2> = new Vector.<Vector2>();
			var cpc:Vector.<int> = getConnectionsPerPoint();
			for ( var i:int = 0; i < points.length; i++ )
			{
				if (connectionsFilter( cpc[i] ) ) result.push( points[i] );
			}
			return result;
		}
		
		public function getLinearPaths():Vector.<LinearPath>
		{
			var result:Vector.<LinearPath> = new Vector.<LinearPath>();
			var currentPath:LinearPath;
			var cc:Vector.<int> = getConnectionsPerPoint();
			var nextIndex:int = 0;
			
			var openEdges:Vector.<Vector.<int>> = new Vector.<Vector.<int>>( points.length, true );
			var edgeCount:int = 0;
			
			for ( var id:String in edges )
			{
				var ids:Array = id.split("|");
				
				if ( openEdges[int(ids[1])] == null ) openEdges[int(ids[1])] = new Vector.<int>();
				if ( openEdges[int(ids[2])] == null ) openEdges[int(ids[2])] = new Vector.<int>();
				openEdges[int(ids[1])].push( ids[2] );
				openEdges[int(ids[2])].push( ids[1] );
				edgeCount++;
			}
			
			while ( nextIndex <  points.length )
			{
				if ( cc[nextIndex] != 2 && openEdges[nextIndex] != null && openEdges[nextIndex].length > 0 )
				{
					currentPath = new LinearPath();
					currentPath.addPoint( points[nextIndex] );
					var currentIndex:int = nextIndex;
					var lastIndex:int = nextIndex;
					do {
						for ( var i:int = openEdges[currentIndex].length; --i > -1; )
						{
							if ( lastIndex != openEdges[currentIndex][i] )
							{
								lastIndex = currentIndex;
								currentIndex = openEdges[currentIndex][i];
								
								for ( var j:int = openEdges[currentIndex].length; --j > -1; )
								{
									if ( openEdges[currentIndex][j] == lastIndex )
									{
										openEdges[currentIndex].splice(j,1);
										break;
									}
								}
								openEdges[lastIndex].splice(i,1);
								
								edgeCount--;
								currentPath.addPoint( points[currentIndex] );
								break;
							}
						}
					} while ( cc[currentIndex] == 2 ) 
					
					result.push ( currentPath );
				} else {
					nextIndex++;
				}
			}
			
			if ( edgeCount > 0 )
			{
				//add closed loops	
				nextIndex = 0;
				while ( nextIndex < points.length )
				{
					if ( openEdges[nextIndex] != null && openEdges[nextIndex].length > 0 )
					{
						currentPath = new LinearPath();
						currentPath.addPoint( points[nextIndex] );
						
						currentIndex = nextIndex;
						lastIndex = nextIndex;
						do {
							var found:Boolean = false;
							
							for ( i = openEdges[currentIndex].length; --i > -1; )
							{
								if ( lastIndex != openEdges[currentIndex][i] )
								{
									lastIndex = currentIndex;
									currentIndex = openEdges[currentIndex][i];
									
									for ( j = openEdges[currentIndex].length; --j > -1; )
									{
										if ( openEdges[currentIndex][j] == lastIndex )
										{
											openEdges[currentIndex].splice(j,1);
											break;
										}
									}
									openEdges[lastIndex].splice(i,1);
									edgeCount--;
									currentPath.addPoint( points[currentIndex] );
									found = true;
									break;
								}
							}
						} while ( found ) 
						result.push ( currentPath );
					} else {
						nextIndex++;
					}
				}
				
			}
			
			return result;
		}
		
		
		public function drawLines( g:Graphics ):void
		{
			for each ( var line:LineSegment in edges )
			{
				line.draw( g );
			}
		}
		
		public function drawPoints( g:Graphics ):void
		{
			for each ( var point:Vector2 in points )
			{
				if ( point != null ) point.draw( g );
			}
		}
		
		public function drawExtras( g:Graphics ):void
		{
			for each ( var point:Vector2 in points )
			{
				if ( point != null ) point.drawCircle( g, 2 );
			}
			/*
			for each ( var line:LineSegment in edges )
			{
				line.drawExtras( g );
			}
			*/
		}
		
		public function showLabels( canvas:Sprite ):void
		{
			for ( var i:int = 0; i< points.length; i++ )
			{
				if ( points[i] != null )
				{
					 points[i].addLabel( i.toString(), canvas );
				}
			}
		}
		
		public function listEdges():String
		{
			var result:String = "";
			for ( var id:String in edges )
			{
				result += id+"\n";
			}
			return result;
		}

	}
}
	import com.quasimondo.geom.LineSegment;
	import __AS3__.vec.Vector;
	import com.quasimondo.geom.Vector2;
	

final internal class ConnectionInfo
{
	public var index1:int;
	public var index2:int;
	public var id1:String;
	public var id2:String;
	public var line:LineSegment;
	
	public function ConnectionInfo( line:LineSegment, index1:int, index2:int ):void
	{
		this.line = line;
		this.index1 = index1;
		this.index2 = index2;
		id1 = "|"+index1+"|";
		id2 = "|"+index2+"|";
			
	}
}

final internal class IntersectionInfo
{
	public var connectionID:String;
	public var intersection:Vector2;
	public var line:LineSegment;
	
	public function IntersectionInfo( intersection:Vector2, connectionID:String, line:LineSegment):void
	{
		this.intersection = intersection;
		this.connectionID = connectionID;
		this.line = line;
		
							
	}
}