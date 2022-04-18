
void server_Pickup(CBlob@ this, CBlob@ picker, CBlob@ pickBlob)
{
	if (pickBlob is null || picker is null || pickBlob.isAttached())
		return;
	CBitStream params;
	params.write_netid(picker.getNetworkID());
	params.write_netid(pickBlob.getNetworkID());
	this.SendCommand(this.getCommandID("pickup"), params);
}

void server_PutIn(CBlob@ this, CBlob@ picker, CBlob@ pickBlob)
{
	CInventory@ inv = this.getInventory();
	if (pickBlob is null || picker is null || !inv.canPutItem(pickBlob))
		return;
	CBitStream params;
	params.write_netid(picker.getNetworkID());
	params.write_netid(pickBlob.getNetworkID());
	this.SendCommand(this.getCommandID("putin"), params);
}

void Tap(CBlob@ this)
{
	this.set_s32("tap_time", getGameTime());
}

void TapPickup(CBlob@ this)
{
	this.set_s32("tap_pickup_time", getGameTime());
}

bool isTap(CBlob@ this, int ticks = 15)
{
	return (getGameTime() - this.get_s32("tap_time") < ticks);
}

bool isTapPickup(CBlob@ this, int ticks = 15)
{
	// TODO: merge some code with the above and make it generalized to all keys if ever useful
	return (getGameTime() - this.get_s32("tap_pickup_time") < ticks);
}


bool PointInsidePolygon( Vec2f Point, Vec2f[] polyVerts, Vec2f polyPos, bool facingLeft )
{
	// Mirror the polygon when the blob is facing left
	// We make a copy, as we do not want to modify the original
    Vec2f[] polygon;

    if (facingLeft) 
    {
      Vec2f[] mirrored;
      for ( int i = 0 ; i < polyVerts.length ; i++ )
      {
        Vec2f q = Vec2f(-polyVerts[i].x, polyVerts[i].y);
        mirrored.push_back(q);
      }

      polygon = mirrored;
    } 
    else 
    {
      polygon = polyVerts;
    }

    double minX = polyPos.x+polygon[0].x;
    double maxX = polyPos.x+polygon[0].x;
    double minY = polyPos.y+polygon[0].y;
    double maxY = polyPos.y+polygon[0].y;

    for ( int i = 1 ; i < polygon.length ; i++ )
    {
        Vec2f q = polyPos+polygon[ i ];
        minX = Maths::Min( q.x, minX );
        maxX = Maths::Max( q.x, maxX );
        minY = Maths::Min( q.y, minY );
        maxY = Maths::Max( q.y, maxY );
    }

    if ( Point.x < minX || Point.x > maxX || Point.y < minY || Point.y > maxY )
    {
        return false;
    }

    bool inside = false;
    for ( int i = 0, j = polygon.length - 1 ; i < polygon.length ; j = i++ )
    {
    	Vec2f pvi = polyPos + polygon[ i ];
    	Vec2f pvj = polyPos + polygon[ j ];
        if ( ( pvi.y > Point.y ) != ( pvj.y > Point.y ) &&
             Point.x < ( pvj.x - pvi.x ) * ( Point.y - pvi.y ) / ( pvj.y - pvi.y ) + pvi.x )
        {
            inside = !inside;
        }
    }

    return inside;
}

