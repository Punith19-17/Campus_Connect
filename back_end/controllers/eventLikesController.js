const db = require("../config/database");

// Like or unlike an event
exports.toggleEventLike = async (req, res) => {
  try {
    const { eventId } = req.params;
    const userId = req.user.id;
    const { isLiked } = req.body;

    // Check if like already exists
    const [existingLike] = await db.execute(
      "SELECT * FROM event_likes WHERE event_id = ? AND user_id = ?",
      [eventId, userId]
    );

    if (existingLike.length > 0) {
      // Update existing like
      await db.execute(
        "UPDATE event_likes SET is_liked = ? WHERE event_id = ? AND user_id = ?",
        [isLiked, eventId, userId]
      );
    } else {
      // Create new like
      await db.execute(
        "INSERT INTO event_likes (event_id, user_id, is_liked) VALUES (?, ?, ?)",
        [eventId, userId, isLiked]
      );
    }

    // Get updated like count
    const [likeCount] = await db.execute(
      "SELECT COUNT(*) as count FROM event_likes WHERE event_id = ? AND is_liked = true",
      [eventId]
    );

    res.json({
      success: true,
      message: isLiked ? "Event liked" : "Event unliked",
      likeCount: likeCount[0].count,
      isLiked: isLiked,
    });
  } catch (error) {
    console.error("Error toggling event like:", error);
    res.status(500).json({
      success: false,
      error: "Failed to toggle event like",
    });
  }
};

// Get event likes count
exports.getEventLikes = async (req, res) => {
  try {
    const { eventId } = req.params;

    const [likeCount] = await db.execute(
      "SELECT COUNT(*) as count FROM event_likes WHERE event_id = ? AND is_liked = true",
      [eventId]
    );

    res.json({
      success: true,
      likeCount: likeCount[0].count,
    });
  } catch (error) {
    console.error("Error getting event likes:", error);
    res.status(500).json({
      success: false,
      error: "Failed to get event likes",
    });
  }
};

// Get user's like status for an event
exports.getUserLikeStatus = async (req, res) => {
  try {
    const { eventId } = req.params;
    const userId = req.user.id;

    const [likeStatus] = await db.execute(
      "SELECT is_liked FROM event_likes WHERE event_id = ? AND user_id = ?",
      [eventId, userId]
    );

    res.json({
      success: true,
      isLiked: likeStatus.length > 0 ? likeStatus[0].is_liked : false,
    });
  } catch (error) {
    console.error("Error getting user like status:", error);
    res.status(500).json({
      success: false,
      error: "Failed to get user like status",
    });
  }
};
